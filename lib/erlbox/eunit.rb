## -------------------------------------------------------------------
##
## Erlang Toolbox: Included tasks for running eunit tests
## Copyright (c) 2009 The Hive.  All rights reserved.
##
## -------------------------------------------------------------------

## -------------------------------------------------------------------
## Constants

EUNIT_SRC = FileList['test/*_tests.erl']
EUNIT_BEAM = EUNIT_SRC.pathmap('%X.beam')
EUNIT_LOG_DIR = TEST_LOG_DIR
EUNIT_WORK_DIR = "#{EUNIT_LOG_DIR}/working"

CLOBBER.include 'coverage'

## -------------------------------------------------------------------
## Tasks

rule '.beam' => "%X.erl" do |t|
  puts "compiling #{t.source}..."
  dir = t.name.pathmap("%d")
  sh "erlc #{print_flags(ERLC_FLAGS)} #{expand_path(ERL_PATH)} -o #{dir} #{t.source}"
end

directory EUNIT_LOG_DIR
directory EUNIT_WORK_DIR

namespace :eunit do

  desc 'Eunit test preparation'
  task :prepare => [EUNIT_LOG_DIR] do
    # Remove the working directory to ensure there isn't stale data laying around
    FileUtils.rm_rf EUNIT_WORK_DIR
    # Always compile tests with debug info
    puts 'Debugging is enabled for test builds.'
    ERLC_FLAGS << '+debug_info'
  end

  desc 'Compile eunit test sources'
  task :compile => ['prepare', 'build:compile'] + EUNIT_BEAM

  desc 'Run eunit tests'
  task :test => [:compile, EUNIT_WORK_DIR] do
    run_eunit('test', ENV['cover'])
  end

end

task :eunit => 'eunit:test'

def run_eunit(dir, cover = false, rest = '')
  puts "running tests in #{dir}#{' with coverage' if cover}..."

  log_dir = abspath(EUNIT_LOG_DIR)

  cover_flags = cover ? "-cover -o #{log_dir}/coverage" : ''

  suites = ENV['suites']
  all_suites = ''
  suites.each(' ') {|s| all_suites << "-s #{s.strip} "} if suites

  script = __FILE__.sub('.rb', '')

  cmd = "cd #{EUNIT_WORK_DIR} &&\
         #{script} -b #{abspath('./ebin')} -l #{log_dir}/eunit.log\
                   #{cover_flags} #{all_suites} #{abspath(dir)}"

  puts cmd.squeeze(' ') if verbose?

  sh cmd
end
