## -------------------------------------------------------------------
##
## Erlang Toolbox: Included tasks for running eunit tests
## Copyright (c) 2009 The Hive.  All rights reserved.
##
## -------------------------------------------------------------------

## -------------------------------------------------------------------
## Constants

EUNIT_SRC = FileList['test/*_tests.erl']
EUNIT_BEAM = EUNIT_SRC.pathmap("%X.beam")

## -------------------------------------------------------------------
## Tasks

rule '.beam' => "%X.erl" do |t|
  puts "compiling #{t.source}..."
  dir = t.name.pathmap("%d")
  sh "erlc #{print_flags(ERLC_FLAGS)} #{expand_path(ERL_PATH)} -o #{dir} #{t.source}"
end

namespace :eunit do

  desc "Compile eunit test sources"
  task :compile => ['build:compile'] + EUNIT_BEAM

  desc "Eunit test preparation"
  task :prepare => :compile do
    # Always compile tests with debug info
    puts "Debugging is enabled for test builds."
    ERLC_FLAGS << '+debug_info'
  end

  desc "Run eunit tests"
  task :test => :prepare do
    run_eunit('test', true)
  end

end

task :eunit => 'eunit:test'

def run_eunit(dir, cover = false, rest = "")
  puts "running tests in #{dir}#{' with coverage' if cover}..."

  config_flags = ""
  if File.exists?("#{dir}/app.config")
    config_flags << " -config #{dir}/app.config"
  end

  cmd = "erl -boot start_clean -noshell #{config_flags} -env TEST_DIR #{dir}\
             -name test@#{`hostname`.strip} -s all_tests test -s erlang halt\
             #{expand_path(ERL_PATH)} -pa #{PWD}/ebin -pa #{dir} -I#{PWD}/include\
             #{cover_flags(dir, cover)} #{rest}"

  puts cmd.squeeze(' ') if verbose?

  sh cmd
end
