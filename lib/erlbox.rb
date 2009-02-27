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

## -------------------------------------------------------------------
## Constants

PWD = Dir.getwd

def debug?
  ENV['ndebug'].nil?
end

ERL_SRC = FileList['src/*.erl']
ERL_BEAM = ERL_SRC.pathmap("%{src,ebin}X.beam")
ERL_PATH = FileList.new
APP_FILE = FileList["#{PWD}/ebin/*.app"][0]

ERL_INCLUDE = "./include"
ERLC_FLAGS = %W( -I#{ERL_INCLUDE} -W )
ERLC_FLAGS << '+debug_info' if debug?

UNIT_TEST_FLAGS = []
INT_TEST_FLAGS  = []
PERF_TEST_FLAGS = []

TEST_ROOT = "."
TEST_LOG_DIR = "#{TEST_ROOT}/logs"

UNIT_TEST_DIR = "#{PWD}/#{TEST_ROOT}/test"
INT_TEST_DIR  = "#{PWD}/#{TEST_ROOT}/int_test"
PERF_TEST_DIR = "#{PWD}/#{TEST_ROOT}/perf_test"

CLEAN.include %w( **/*.beam **/erl_crash.dump )
CLOBBER.include TEST_LOG_DIR, 'doc'

## -------------------------------------------------------------------
## Rules

directory 'ebin'

rule ".beam" => ["%{ebin,src}X.erl"] do |t|
  puts "compiling #{t.source}..."
  sh "erlc #{print_flags(ERLC_FLAGS)} #{expand_path(ERL_PATH)} -o ebin #{t.source}", :verbose => false
end

## -------------------------------------------------------------------
## Tasks

desc "Compile Erlang sources to .beam files"
task :compile => ['ebin'] + ERL_BEAM do
  do_validate_app(APP_FILE)
end

desc "Do a fresh build from scratch"
task :rebuild => [:clean, :compile]

desc "Generate Edoc documentation"
task :doc do
  app = erl_app_name(APP_FILE)
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

desc "Package app for publication to a faxien repo"
task :package => [:compile] do
  target_dir = package_dir
  FileUtils.rm_rf target_dir
  Dir.mkdir target_dir
  FileUtils.cp_r 'ebin', target_dir, :verbose => false
  FileUtils.cp_r 'include', target_dir, :verbose => false
  FileUtils.cp_r 'src', target_dir, :verbose => false
  FileUtils.cp_r 'priv', target_dir, :verbose => false if File.exist?('priv')
  puts "Packaged to #{target_dir}"
end

task :default => [:compile]

## -------------------------------------------------------------------
## Public functions

def append_flags(flags, value)
  flags << value
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

def erl_app_version(app)
  script = <<-ERL
     ok = application:load(#{app}),
     {ok, Vsn} = application:get_key(#{app}, vsn),
     io:format("~s\\n", [Vsn]).
     ERL
  output = erl_run(script, "-pa ebin")
  output.strip()
end

def erl_app_name(app_file)
  File.basename(app_file, ".app")
end

def package_dir
  app = erl_app_name(APP_FILE)
  vsn = erl_app_version(app)
  "#{app}-#{vsn}"
end


## -------------------------------------------------------------------
## Private functions

def print_flags(flags)
  flags.join(' ')
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
  app = erl_app_name(app_file)
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
  eval("#{type.to_s.upcase}_TEST_DIR")
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

  config_flags = ""
  if File.exists?("#{dir}/test.config")
    config_flags << "-ct_config #{dir}/test.config"
  end

  if File.exists?("#{dir}/app.config")
    config_flags << " -config #{dir}/app.config"
  end

  cmd = "erl #{expand_path(ERL_PATH)} -pa #{PWD}/ebin #{PWD}/include\
             -noshell\
             -s ct_run script_start\
             -s erlang halt\
             -name test@#{`hostname`.strip}\
             #{cover_flags(dir, cover)}\
             #{get_suites(dir)}\
             -logdir #{TEST_LOG_DIR}\
             -env TEST_DIR #{dir}\
             #{config_flags} #{rest}"

  if !defined?(NOISY_TESTS) && ENV["verbose"].nil?
    output = `#{cmd}`

    fail if $?.exitstatus != 0 && !ENV["stop_on_fail"].nil?

    File.open("#{PWD}/#{TEST_LOG_DIR}/raw.log", "w") do |file|
      file.write "--- Test run on #{Time.now.to_s} ---\n"
      file.write output
      file.write "\n\n"
    end

    if output[/, 0 failed/]
      puts "==> " + output[/TEST COMPLETE,.*test cases$/]
    else
      puts output
    end
  else
    puts cmd.squeeze(' ')
    sh cmd
  end
end

def cover_flags(dir, use_cover)
  use_cover ? "-cover #{dir}/cover.spec" : ""
end

def get_suites(dir)
  suites = ENV['suites']
  if suites
    all_suites = ""
    suites.each(' ') {|s| all_suites << "#{dir}/#{s.strip}_SUITE "}
    "-suite #{all_suites}"
  else
    "-dir #{dir}"
  end
end
