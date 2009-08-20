## -------------------------------------------------------------------
##
## Erlang Toolbox: Rake Utilities
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

require 'yaml'
require 'uri'
include FileUtils

def debug?
  !ENV['debug'].nil?
end

def verbose?
  !ENV['verbose'].nil?
end

def print_flags(flags)
  flags.join(' ')
end

def append_flags(flags, value)
  flags << value
end

def abspath(path)
  Pathname.new(path).realpath.to_s
end

def expand_path(path)
  # erlc requires multiple -pa arguments and erl supports it
  # so I am treating them the same here
  path.empty? ? '' : "-pa #{path.join(' -pa ')}"
end

def erl_run(script, args = "", extra_args = {})
  if extra_args[:erl_root]
    cmd = File.join(extra_args[:erl_root], "bin", "erl")
  else
    cmd = "erl"
  end
  `#{cmd} -eval '#{script}' -s erlang halt #{args} -noshell 2>&1`.strip
end

def erts_version()
  script = <<-ERL
      io:format("~s\n", [erlang:system_info(version)]).
      ERL
  erl_run(script)
end

def erl_where(lib, dir = 'include')
  script = <<-ERL
      io:format("~s\n", [filename:join(code:lib_dir(#{lib}), #{dir})])
      ERL
  erl_run(script)
end

def erl_root()
  script = <<-ERL
     io:format("~s\n", [code:root_dir()])
     ERL
  erl_run(script)
end

def erl_app_version(app, extra_args = {})
  script = <<-ERL
     application:load(#{app}),
     {ok, Vsn} = application:get_key(#{app}, vsn),
     io:format("~s\\n", [Vsn]).
     ERL
  output = erl_run(script, "-pa ebin", extra_args)
  output.strip()
end

def erl_app_modules(app)
  script = <<-ERL
      application:load(#{app}),
      {ok, M} = application:get_key(#{app}, modules),
      [io:format("~s\\n", [Mod]) || Mod <- M].
      ERL

  output = erl_run(script, "-pa ebin")
  if output[/badmatch/]
    puts "Error processing .app file: #{output}"
    []
  else
    output.split("\n")
  end
end

def erl_app_applications(app)
  script = <<-ERL
      ok = application:load(#{app}),
      {ok, A} = application:get_key(#{app}, applications),
      [io:format("~s\\n", [App]) || App <- A].
      ERL

  output = erl_run(script, "-pa ebin")
  if output[/badmatch/]
    puts "Error processing .app file: #{output}"
    []
  else
    output.split("\n")
  end
end

def erl_app_versioned_dependencies(app)
  script = <<-ERL
    {ok, [{application, _AppName, AppConfig}]} = file:consult("ebin/#{app}.app"),
    VDeps = case lists:keyfind(versioned_dependencies, 1, AppConfig) of
      {versioned_dependencies, Deps} -> Deps;
      Other -> []
    end,

    [io:format("~p~n", [tuple_to_list(Dep)]) || Dep <- VDeps].
  ERL

  output = erl_run(script, "-pa ebin")

  # maps from a string to a list of lists, where each list is:
  # [app, version, nil | gt | gte | e]
  # (less than, less than or equal, etc.)
  deps = output.split("\n").map{|d| d.gsub(/[\[\"\']/, '').split(',')}

  deps
end

def erl_app_needs_upgrade?(app, requested_ver)
  # if it's nil, force us to have something installed
  requested_ver ||= '0.0.0.001' 

  installed_ver = erl_app_version(app)

  if installed_ver =~ /init terminating/
    installed_ver = "0.0.0"
  end

  return erl_version_needs_upgrade?(installed_ver, requested_ver)
end

def erl_version_needs_upgrade?(installed_version, requested_version)
  iv = installed_version.split('.')
  rv = requested_version.split('.')

  iv.each_with_index do |n, i|
    if rv[i].nil?
      # installed version is longer, and all previous parts equal
      return false
    elsif rv[i].to_i > iv[i].to_i
      return true # requested version is greater
    elsif iv[i].to_i > rv[i].to_i
      return false # installed version is greater
    end
  end

  if rv.length > iv.length
    return true # they're equal, but requested version has extra
  else
    return false # they're equal
  end
end

def erl_install_dependencies(app)
  erl_app_versioned_dependencies(app).each do |dep|
    erl_install_dep(*dep)
  end

  erl_app_applications(app).each do |dep|
    erl_install_dep(dep)
  end
end

##
# It appears that faxien allows us to specify that a version must
# be exactly equal to the requested version. I'm ignoring this for now,
# but in this case, the extra argument here would be 'e'
##
def erl_install_dep(app, ver = nil, extra = nil)
  appstr = ver ? "#{app}-#{ver}" : "#{app}"

  if erl_app_needs_upgrade?(app, ver)
    # do we have a ~/.erlbox.yaml file?
    
    puts "Trying to install #{appstr}..."
    erl_install_app(app)

    # Check again, to make sure it was installed correctly
    if erl_app_needs_upgrade?(app, ver)
      STDERR.puts "ERROR: Failed to install dependency #{appstr}"
      exit(1)
    end
  end
end

def load_yaml(file)
  filename = File.expand_path(file)
  return nil if not File.exist?(filename)
  YAML::load(File.read(filename))
end

def load_config()
  # Check for existence of the config file -- we MUST have one
  config = load_yaml("~/.erlbox.yaml")

  # Load the file and make sure required parameters are present
  if config.nil? || config.empty?
    STDERR.puts "To install dependencies from source, you must have a ~/.erlbox.yaml file with the key 'default_repo' (where git sources are) and optional keys 'erlang' (erlang root) and 'site_dir' (where to install applications. This must be in your ERL_LIBS path)"
    config = []
  end

  # Fix up default repo URL
  if config.has_key?('default_repo')
    url = URI(config['default_repo'])
    if url.scheme == nil or url.scheme == "file":
        config['defaut_repo'] = File.expand_path(url.path)
    end
  end

  # If erlang repo is specified, expand the path and use that to determine the root
  if config.has_key?('erlang')
    config['erlang_root'] = erl_root(File.expand_path(config['erlang'])).strip()
  else
    config['erlang_root'] = erl_root().strip()
  end

  if !config.has_key?('site_dir')
    config['site_dir'] = File.join(config['erlang_root'], "lib")
  end

  config
end

# install the latest version of the requested app
def erl_install_app(appname)
  config = load_config()
  if config.empty?
    STDERR.puts "Sorry, we currently only support installing dependencies from source"
    exit 1
  end

  # TODO: deal with other schemes than just files
  workdir = File.join(config['default_repo'], appname)
  if !File.exist?(workdir)
    STDERR.puts "No such directory: #{workdir}"
    exit 1
  end

  cd workdir
  sh "rake install"
end

##
# install the current app without checking dependencies
##
def erl_install
  config = load_config()

  appid = "#{APP_NAME}-#{erl_app_version(APP_NAME)}"
  install_dir = File.join(config['site_dir'], appid)

  if File.exist?(install_dir)
    rm_rf install_dir
  end

  mkdir install_dir
  ['ebin', 'src', 'include', 'priv', 'mibs', 'deps'].each do |dir|
    cp_r dir, install_dir if File.exist?(dir)
  end

  puts "Successfully installed #{appid} into #{install_dir}"
end

# Returns true if running on Linux
def linux?
  platform? 'linux'
end

# Returns true if running on Darwin/MacOS X
def darwin?
  platform? 'darwin'
end

def platform?(name)
  RUBY_PLATFORM =~ /#{name}/i
end
