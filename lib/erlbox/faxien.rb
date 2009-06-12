## -------------------------------------------------------------------
##
## Erlang Toolbox: Included tasks for packaging and publishing to Faxien
## Copyright (c) 2008 The Hive http://www.thehive.com/
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
    FileUtils.cp_r 'mibs', PACKAGE_DIR if File.exist?('mibs')
    puts "Packaged to #{PACKAGE_DIR}"
  end

  desc "Publish a packaged application to a faxien repo"
  task :publish do
    sh "faxien publish #{PACKAGE_DIR}"
  end

end

task :faxien => ['faxien:package', 'faxien:publish']
