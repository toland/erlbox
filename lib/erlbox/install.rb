## -------------------------------------------------------------------
##
## Erlang Toolbox: Helper tasks for installing an app into erlang
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

task :install => [:'install:build', :'install:deps'] do
  erl_install()
end

task :install_no_deps => [:'install:build'] do
  erl_install()
end

namespace :install do

  task :appid, [:root_dir] do |t, args|
    puts "#{APP_NAME}-#{erl_app_version(APP_NAME, :erl_root => args.root_dir)}"
  end

  desc "Hook to allow bootstrapping a new repo during installation"
  task :prepare

  desc "Build the application for installation"
  task :build => [:compile]

  desc "Installs all the dependencies for the current app"
  task :deps do
    erl_install_dependencies(APP_NAME)
  end
end
