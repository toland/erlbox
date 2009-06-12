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

namespace :erlbox do
  
  desc "Install the application into the specified Erlang root"
  task :install => [:compile]
  task :install, [:root_dir] do | t, args |
    appid = APP_NAME + "-" + erl_app_version(APP_NAME, :erl_root => args.root_dir)
    install_dir = File.join(args.root_dir, "lib", appid)

    # Check that the target directory doesn't already exist -- bail if it does
    if File.directory?(install_dir)
      puts "#{appid} has already been installed!"
      exit 1
    end

    puts "Installing to #{install_dir}"
    FileUtils.mkdir install_dir
    FileUtils.cp_r 'ebin', install_dir
    FileUtils.cp_r 'src', install_dir
    FileUtils.cp_r 'include', install_dir if File.exist?('include')
    FileUtils.cp_r 'priv', install_dir if File.exist?('priv')
    FileUtils.cp_r 'mibs', install_dir if File.exist?('mibs')
  end

end
  
