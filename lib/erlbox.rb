## -------------------------------------------------------------------
##
## Erlang Toolbox: Bootstrap file
## Copyright (c) 2008 The Hive.  All rights reserved.
##
## -------------------------------------------------------------------

require 'set'
require 'rake'
require 'rake/clean'
require 'pathname'

libdir = Pathname(__FILE__).dirname
$:.unshift(libdir) unless $:.include?(libdir) || $:.include?(libdir.expand_path)

verbose false

require 'erlbox/utils'
require 'erlbox/build'
require 'erlbox/test'
require 'erlbox/eunit'
require 'erlbox/edoc'
require 'erlbox/faxien'
require 'erlbox/dialyzer'
