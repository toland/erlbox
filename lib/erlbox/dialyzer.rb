## -------------------------------------------------------------------
##
## Erlang Toolbox: Included tasks for running Dialyzer
## Copyright (c) 2008 The Hive.  All rights reserved.
##
## -------------------------------------------------------------------

## -------------------------------------------------------------------
## Constants

PLT_LIBS = %w( kernel stdlib )
PLT_FILE = "#{ENV['HOME']}/.dialyzer_plt"

CLEAN.include 'dialyzer.log'

## -------------------------------------------------------------------
## Rules

rule PLT_FILE do
  puts "generating base PLT file..."
  `dialyzer --build_plt -r #{erl_where('kernel', 'ebin')} --plt #{PLT_FILE}`
end

## -------------------------------------------------------------------
## Tasks

namespace :dialyzer do

  desc "Update your PLT file with the libraries required by this application"
  task :update_plt => PLT_FILE do
    PLT_LIBS.each do |lib|
      puts "adding #{lib} to plt..."
      `dialyzer --add_to_plt -r #{erl_where(lib, 'ebin')} --plt #{PLT_FILE}`
    end

    ERL_PATH.each do |app|
      puts "adding #{app} to plt..."
      `dialyzer --add_to_plt -r #{app} --plt #{PLT_FILE}`
    end
  end

  task :prepare do
    ERLC_FLAGS << '+debug_info'
  end

  desc "Run Dialyzer on the compiled beam files"
  task :run => [:prepare] + ERL_BEAM do
    warnings = ENV['WARN']
    if !warnings.nil? && !warnings.empty?
      warn_opts = ' -W' + warnings.split(',').join(' -W')
    else
      warn_opts = ''
    end

    sh "dialyzer -Iinclude -r ebin --plt #{PLT_FILE}\
                 -Werror_handling -Wunmatched_returns #{warn_opts} | tee dialyzer.log"
  end

end

task :dialyzer => 'dialyzer:run'
