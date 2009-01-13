## -------------------------------------------------------------------
##
## Erlang Toolbox: Rake Utilities
## Copyright (c) 2008 The Hive.  All rights reserved.
##
## -------------------------------------------------------------------

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
