## -------------------------------------------------------------------
##
## Erlang Toolbox: OTP release tasks
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
require 'erb'
require 'rake/clean'
require 'erlbox/utils'
require 'yaml'
include FileUtils

def build_node(nodefile)
  # Load the YAML descriptor
  node_desc = load_node_yaml(nodefile)

  # Pull out vars we'll need often
  relname = node_desc['release']
  relvers = node_desc['version']
  relid = "#{relname}-#{relvers}"
  erts_vsn = erts_version()

  # Merge list of apps into a space separated string
  apps = node_desc['apps'].join(' ')

  # Run the make-rel script -- this will yield the following files:
  # <relname>-<relver>.[boot, rel, script, .tar.gz]
  reltools_dir = File.join(File.dirname(__FILE__), "reltools")
  script = File.join(reltools_dir, "make-rel")
  cmd = "#{script} #{relname} #{relvers} #{node_desc['code_path']} #{apps}"
  sh cmd

  # Unpack the systool generated tarball
  FileUtils.remove_dir(relname, force = true)
  FileUtils.mkdir(relname)
  sh "tar -xzf #{relid}.tar.gz -C #{relname}"

  # Cleanup interstitial files from systools
  FileUtils.remove(["#{relid}.boot", "#{relid}.script", "#{relid}.rel", "#{relid}.tar.gz"])

  # Create release file
  File.open("#{relname}/releases/start_erl.data", 'w') { |f| f.write("#{erts_vsn} #{relvers}\n") }

  # Copy overlay into place (if present)
  if node_desc.has_key?('overlay')
    sh "cp -R #{node_desc['overlay']}/* #{relname}" # Had issues with FileUtils.cp_r doing wrong thing
  end

  # Remove any files from the erts bin/ that are scripts -- we want only executables
  erts_bin = File.join(relname, "erts-" + erts_vsn, "bin")
  sh "rm -f `file #{erts_bin}/* |grep Bourne|awk -F: '{print $1}'`"

  # Copy nodetool into erts-<vsn>/bin 
  FileUtils.cp(File.join(reltools_dir, "nodetool"), erts_bin)

  # Copy our custom erl.sh and the necessary .boot file into erts-<vsn>/bin. This is necessary
  # to enable escript to work properly
  FileUtils.cp(File.join(reltools_dir, "erl.sh"), File.join(erts_bin, "erl"))
  FileUtils.cp(File.join(erl_root(), "bin", "start.boot"), File.join(erts_bin, "erl.boot"))

  # Create any requested empty-dirs
  if node_desc.has_key?('empty_dirs')
    node_desc['empty_dirs'].each { |d| FileUtils.mkdir_p(File.join(relname, d)) }
  end

  # Make sure bin directory exists and copy the runner
  FileUtils.mkdir_p File.join(relname, "bin")
  cp File.join(reltools_dir, "runner"), File.join(relname, "bin", relname)
  chmod 0755, File.join(relname, "bin", relname)
  
end


def load_node_yaml(file)
  # Load the YAML file
  filename = File.expand_path(file)
  fail "Node descriptor #{filename} does not exit!" if not File.exist?(filename)
  node = YAML::load(File.read(filename))

  # Make sure a release name and version are specified
  if !node.has_key?('release') or !node.has_key?('version')
    fail "Node descriptor must have a release and version specified."
  end

  # Make sure code path is swathed with quotes so that wildcards won't get processed by
  # shell
  if node.has_key?('code_path')
    node['code_path'] = "\'#{node['code_path']}\'"
  else
    # If no code path is specified set an empty one
    node['code_path'] = '""'
  end

  return node
end


## Setup a series of dynamic targets, based on the information available in the .node file.
FileList['*.node'].each do |src|
  name = src.pathmap("%X")
  node_desc = load_node_yaml(src)

  if node_desc != nil
    relname = node_desc['release']
    relvers = node_desc['version']
    target = "#{relname}/releases/#{relname}-#{relvers}.rel"

    # Construct task with base node name -- depends on the .rel file
    desc "Builds #{relname} node"
    task name => target

    # .rel file is used for detecting if .node file changes and forcing a rebuild
    file target => [src] do
      build_node(src)
    end

    # Add release target (creates a tarball)
    desc "Package #{relname} into a tarball"
    task "#{name}:package" => [name] do
      mv(name, "#{relname}-#{relvers}")
      sh "tar -cjf #{relname}-#{relvers}-#{RUBY_PLATFORM}.tar.bz2 #{relname}-#{relvers}"
      rm_rf("#{relname}-#{relvers}")
    end

    # Add cleanup target
    desc "Clean #{relname} node"
    task "#{name}:clean" do
        FileUtils.remove_dir "#{relname}", true
        FileUtils.remove Dir.glob("#{relname}-#{relvers}.*")
      end

    # Register cleanup stuff with clobber
    CLOBBER.include << "#{relname}" << "#{relname}-#{relvers}.*"
  end
end

# task :build_app do
#   cd "../apps" do
#     sh "rake"
#   end
# end

