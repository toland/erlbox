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

CLOBBER.include 'coverage'

## -------------------------------------------------------------------
## Tasks

rule '.beam' => "%X.erl" do |t|
  puts "compiling #{t.source}..."
  dir = t.name.pathmap("%d")
  sh "erlc #{print_flags(ERLC_FLAGS)} #{expand_path(ERL_PATH)} -o #{dir} #{t.source}"
end

namespace :eunit do

  desc 'Eunit test preparation'
  task :prepare do
    # Always compile tests with debug info
    puts 'Debugging is enabled for test builds.'
    ERLC_FLAGS << '+debug_info'
  end

  desc 'Compile eunit test sources'
  task :compile => ['prepare', 'build:compile'] + EUNIT_BEAM

  desc 'Run eunit tests'
  task :test => :compile do
    run_eunit('test', ENV['cover'])
  end

end

task :eunit => 'eunit:test'

def run_eunit(dir, cover = false, rest = '')
  puts "running tests in #{dir}#{' with coverage' if cover}..."

  cover_flags = cover ? '-cover' : ''

  suites = ENV['suites']
  all_suites = ''
  suites.each(' ') {|s| all_suites << "-s #{s.strip} "} if suites

  script = __FILE__.sub('.rb', '')

  cmd = "#{script} -b ./ebin #{cover_flags} #{all_suites} #{dir}"

  puts cmd.squeeze(' ') if verbose?

  sh cmd
end
