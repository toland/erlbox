## -------------------------------------------------------------------
##
## Erlang Toolbox: Bootstrap file
## Copyright (c) 2008 The Hive.  All rights reserved.
##
## -------------------------------------------------------------------

require 'set'
require 'pathname'
require 'rubygems'

gem 'rake'
require 'rake'
require 'rake/clean'

libdir = Pathname(__FILE__).dirname
$:.unshift(libdir) unless $:.include?(libdir) || $:.include?(libdir.expand_path)

require 'erlbox/helpers'
require 'erlbox/version'
include ErlBox::Helpers

PWD = Dir.getwd

ERL_SRC = FileList['src/*.erl']
ERL_BEAM = ERL_SRC.pathmap("%{src,ebin}X.beam")
ERL_PATH = FileList.new
APP_FILE = FileList["#{PWD}/ebin/*.app"][0]

ERL_INCLUDE = "./include"
ERLC_FLAGS = %W( -I#{ERL_INCLUDE} -W )
ERLC_FLAGS << '+debug_info' if ENV['ndebug'].nil?

UNIT_TEST_FLAGS = []
INT_TEST_FLAGS  = []
PERF_TEST_FLAGS = []

TEST_ROOT = "tests"
TEST_LOG_DIR = "#{TEST_ROOT}/logs"

UNIT_TEST_DIR = "#{PWD}/#{TEST_ROOT}/unit_test"
INT_TEST_DIR  = "#{PWD}/#{TEST_ROOT}/int_test"
PERF_TEST_DIR = "#{PWD}/#{TEST_ROOT}/perf_test"

CLEAN.include %w( **/*.beam **/erl_crash.dump )
CLOBBER.include TEST_LOG_DIR, 'doc'

directory 'ebin'

rule ".beam" => ["%{ebin,src}X.erl"] do |t|
  puts "compiling #{t.source}..."
  sh "erlc #{print_flags(ERLC_FLAGS)} #{expand_path(ERL_PATH)} -o ebin #{t.source}", :verbose => false
end

desc "Compile Erlang sources to .beam files"
task :compile => ['ebin'] + ERL_BEAM do
  do_validate_app(APP_FILE)
end

desc "Do a fresh build from scratch"
task :rebuild => [:clean, :compile]

desc "Generate Edoc documentation"
task :doc do
  app = File.basename(APP_FILE, ".app")
  sh %Q(erl -noshell -run edoc_run application #{app} '"."' "[]"  -s init stop)
end

namespace :test do

  desc "Test preparation run before all tests"
  task :prepare do
    fail "No tests defined" unless File.directory?(TEST_ROOT)
    Dir.mkdir(TEST_LOG_DIR) unless File.directory?(TEST_LOG_DIR)
  end

  task :results do
    `open #{TEST_LOG_DIR}/index.html`
  end

  ['unit', 'int', 'perf'].each do |type|
    desc "Run #{type} tests"
    task type => "test:#{type}:prepare" do
      check_and_run_tests(type, false)
    end

    namespace type do
      desc "Prepare #{type} tests"
      task :prepare => ['compile', '^prepare']

      desc "Compile #{type} tests"
      task :compile => 'rake:compile' do
        compile_tests(type)
      end

      desc "Run #{type} tests with coverage"
      task :cover => :prepare do
        check_and_run_tests(type, true)
      end
    end
  end

  desc "Run all tests"
  task :all => [:unit, :int, :perf]

end

# Convenience tasks for backward compatibility
task :test => 'test:unit'
task :int_test => 'test:int'
task :perf_test => 'test:perf'

task :default => [:compile]

def append_flags(flags, value)
  flags << value
end

def print_flags(flags)
  flags.join(' ')
end

def erl_run(script, args = "") 
  `erl -eval '#{script}' -s erlang halt #{args} -noshell 2>&1`.strip
end

def erl_where(lib)
  script = <<-ERL
      io:format("~s\n", [filename:join(code:lib_dir(#{lib}), "include")])
      ERL
  erl_run(script)
end

def erl_app_modules(app)
  script = <<-ERL
      ok = application:load(#{app}),
      {ok, M} = application:get_key(#{app}, modules),
      [io:format("~s\\n", [Mod]) || Mod <- M].
      ERL

  output = erl_run(script, "-pa ebin")
  if output[/badmatch/]
    fail "Error processing .app file: ", output
  else
    output.split("\n")
  end
end

def do_validate_app(app_file)
  # Setup app name and build sets of modules from the .app as well as
  # beams that got compiled
  app = File.basename(app_file, ".app")
  modules = Set.new(erl_app_modules(app))
  beams = Set.new(ERL_BEAM.pathmap("%n").to_a)

  puts "validating #{app}.app..."

  # Identify .beam files which are listed in the .app, but not present in ebin/
  missing_beams = (modules - beams)
  if not missing_beams.empty?
    msg = "One or more modules listed in #{app}.app do not exist as .beam:\n"
    missing_beams.each { |m| msg << " * #{m}\n" }
    fail msg
  end

  # Identify modules which are not listed in the .app, but are present in ebin/
  missing_modules = (beams - modules)
  if not missing_modules.empty? 
    msg = "One or more .beam files exist that are not listed in #{app}.app:\n"
    missing_modules.each { |m| msg << "  * #{m}\n" }
    fail msg
  end
end

def test_dir(type)
  "#{TEST_ROOT}/#{type.to_s}_test"
end

def expand_path(path)
  # erlc requires multiple -pa arguments and erl supports it
  # so I am treating them the same here
  path.empty? ? '' : "-pa #{path.join(' -pa ')}"
end

def compile_tests(type)
  # Is this necessary? I don't think so since CT compiles code itself.
  dir = test_dir(type)
  if File.directory?(dir)
    compile_cmd = "erlc -I#{erl_where('common_test')} -I#{erl_where('test_server')}\
                        #{print_flags(ERLC_FLAGS)} #{expand_path(ERL_PATH)}\
                        -o #{dir} #{dir}/*.erl"

    sh compile_cmd, :verbose => false
  end  
end

def check_and_run_tests(type, use_cover = false)
  dir = test_dir(type)
  if File.directory?(dir)
    run_tests(dir, use_cover, print_flags(eval("#{type.upcase}_TEST_FLAGS")))
  else
    puts "No #{type} tests defined. Skipping."
  end
end

def run_tests(dir, cover = false, rest = "")
  puts "running tests in #{dir}#{' with coverage' if cover}..."

  output = `erl #{expand_path(ERL_PATH)} #{PWD}/include\
                -noshell\
                -s ct_run script_start\
                -s erlang halt\
                -name test@#{`hostname`.strip}\
                #{cover_flags(dir, cover)}\
                #{get_suites(dir)}\
                -logdir #{TEST_LOG_DIR}\
                -env TEST_DIR #{PWD}/#{dir}\
                #{rest}`

  fail if $?.exitstatus != 0 && !ENV["stop_on_fail"].nil?

  File.open("#{PWD}/#{TEST_LOG_DIR}/raw.log", "w") do |file|
    file.write "--- Test run on #{Time.now.to_s} ---\n"
    file.write output
    file.write "\n\n"
  end

  if output[/, 0 failed/] && ENV["verbose"].nil?
    puts "==> " + output[/TEST COMPLETE,.*test cases$/]
  else
    puts output
  end
end

def cover_flags(dir, use_cover)
  use_cover ? "-cover #{dir}/cover.spec" : ""
end

def get_suites(dir)
  suites = ENV['suites']
  if suites
    all_suites = ""
    suites.each(' ') {|s| all_suites << "#{PWD}/#{dir}/#{s.strip}_SUITE "}
    "-suite #{all_suites}"
  else
    "-dir #{dir}"
  end
end
