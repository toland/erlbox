## -------------------------------------------------------------------
##
## Erlang Toolbox: Included tasks for running eunit tests
## Copyright (c) 2009 The Hive http://www.thehive.com/
##
## Permission is hereby granted, free of charge, to any person obtaining a copy
## of this software and associated documentation files (the "Software"), to deal
## in the Software without restriction, including without limitation the rights
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
## copies of the Software, and to permit persons to whom the Software is
## furnished to do so, subject to the following conditions:
##
## The above copyright notice and this permission notice shall be included in
## all copies or substantial portions of the Software.
##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
## THE SOFTWARE.
##
## -------------------------------------------------------------------

## -------------------------------------------------------------------
## Constants

EUNIT_SRC = FileList['test/*.erl']
EUNIT_SRC.exclude('test/*_SUITE.erl') # exclude CT suites

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

## -------------------------------------------------------------------
## Helpers

def run_eunit(dir, cover = false, rest = '')
  puts "running tests in #{dir}#{' with coverage' if cover}..."

  log_dir = abspath(EUNIT_LOG_DIR)

  cover_flags = cover ? "-cover -o #{log_dir}/coverage" : ''
  verbose_flags = verbose? ? '-v' : ''

  suites = ENV['suites']
  all_suites = ''
  suites.each(' ') {|s| all_suites << "-s #{s.strip} "} if suites

  script = __FILE__.sub('.rb', '')

  cmd = "cd #{EUNIT_WORK_DIR} &&\
         #{script} #{verbose_flags} #{expand_erl_path()} \
                   -b #{abspath('./ebin')} -l #{log_dir}/eunit.log\
                   #{cover_flags} #{all_suites} #{abspath(dir)}"

  puts cmd.squeeze(' ') if verbose?

  sh cmd
end

def expand_erl_path()
  # Add the ERL_PATH includes using multiple -b arguments 
  ERL_PATH.empty? ? '' : "-b #{ERL_PATH.join(' -b ')}"
end
