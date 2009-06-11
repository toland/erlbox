## -------------------------------------------------------------------
##
## Erlang Toolbox: Helper tasks for installing an app into erlang
## Copyright (c) 2009 The Hive.  All rights reserved.
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
    FileUtils.cp_r 'ebin', install_dir
    FileUtils.cp_r 'src', install_dir
    FileUtils.cp_r 'include', install_dir if File.exist?('include')
    FileUtils.cp_r 'priv', install_dir if File.exist?('priv')
    FileUtils.cp_r 'mibs', install_dir if File.exist?('mibs')
  end

end
  
