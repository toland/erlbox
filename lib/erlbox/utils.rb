## -------------------------------------------------------------------
##
## Erlang Toolbox: Rake Utilities
## Copyright (c) 2008 The Hive.  All rights reserved.
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

def expand_path(path)
  # erlc requires multiple -pa arguments and erl supports it
  # so I am treating them the same here
  path.empty? ? '' : "-pa #{path.join(' -pa ')}"
end

def erl_run(script, args = "")
  `erl -eval '#{script}' -s erlang halt #{args} -noshell 2>&1`.strip
end

def erl_where(lib, dir = 'include')
  script = <<-ERL
      io:format("~s\n", [filename:join(code:lib_dir(#{lib}), #{dir})])
      ERL
  erl_run(script)
end

def erl_app_version(app)
  script = <<-ERL
     ok = application:load(#{app}),
     {ok, Vsn} = application:get_key(#{app}, vsn),
     io:format("~s\\n", [Vsn]).
     ERL
  output = erl_run(script, "-pa ebin")
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
