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
     ok = application:load(#{app}),
     {ok, Vsn} = application:get_key(#{app}, vsn),
     io:format("~s\\n", [Vsn]).
     ERL
  output = erl_run(script, "-pa ebin", extra_args)
  output.strip()
end

def erl_app_modules(app)
  script = <<-ERL
      ok = application:load(#{app}),
      {ok, M} = application:get_key(#{app}, modules),
      [io:format("~s\\n", [Mod]) || Mod <- M].
      ERL

  output = erl_run(script, "-pa ebin")
  if output[/badmatch/]
    puts "Error processing .app file: #{output}"
  else
    output.split("\n")
  end
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
