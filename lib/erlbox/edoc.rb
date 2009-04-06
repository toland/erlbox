## -------------------------------------------------------------------
##
## Erlang Toolbox: Included tasks for building edoc documentation
## Copyright (c) 2008 The Hive.  All rights reserved.
##
## -------------------------------------------------------------------

## -------------------------------------------------------------------
## Constants

CLOBBER.include 'doc'

## -------------------------------------------------------------------
## Tasks

namespace :edoc do

  desc "Generate Edoc documentation"
  task :run do
    sh %Q(erl -noshell -run edoc_run application #{APP_NAME} '"."' "[]"  -s init stop)
  end

end

task :edoc => 'edoc:run'
