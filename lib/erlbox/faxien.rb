## -------------------------------------------------------------------
##
## Erlang Toolbox: Included tasks for packaging and publishing to Faxien
## Copyright (c) 2008 The Hive.  All rights reserved.
##
## -------------------------------------------------------------------

## -------------------------------------------------------------------
## Constants

PACKAGE_DIR="#{APP_NAME}-#{erl_app_version(APP_NAME)}"

CLOBBER.include PACKAGE_DIR

## -------------------------------------------------------------------
## Rules

directory PACKAGE_DIR

## -------------------------------------------------------------------
## Tasks

namespace :faxien do

  desc "Prepare the application for packaging"
  task :prepare do
    FileUtils.rm_rf PACKAGE_DIR
  end

  desc "Package app for publication to a faxien repo"
  task :package => [:prepare, PACKAGE_DIR] do
    FileUtils.cp_r 'ebin', PACKAGE_DIR
    FileUtils.cp_r 'src', PACKAGE_DIR
    FileUtils.cp_r 'include', PACKAGE_DIR if File.exist?('include')
    FileUtils.cp_r 'priv', PACKAGE_DIR if File.exist?('priv')
    puts "Packaged to #{PACKAGE_DIR}"
  end

  desc "Publish a packaged application to a faxien repo"
  task :publish do
    sh "faxien publish #{PACKAGE_DIR}"
  end

end

task :faxien => ['faxien:package', 'faxien:publish']
