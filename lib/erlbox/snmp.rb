## -------------------------------------------------------------------
##
## Erlang Toolbox: Optional SNMP Tasks
## Copyright (c) 2008 The Hive.  All rights reserved.
##
## -------------------------------------------------------------------

if !defined?(APP_NAME)
  fail "You must require 'erlbox' before requiring this file"
end

## -------------------------------------------------------------------
## Constants

MIBS_DIR = 'priv/mibs'
MIB_SRCS = FileList["mibs/*.mib"]
MIB_BINS = MIB_SRCS.pathmap("%{mibs,#{MIBS_DIR}}X.bin")

CLEAN.include MIBS_DIR

## -------------------------------------------------------------------
## Rules

directory MIBS_DIR

rule ".bin" => ["%{#{MIBS_DIR},mibs}X.mib"] do |t|
  puts "compiling #{t.source}..."
  sh "erlc -I #{MIBS_DIR} -o #{MIBS_DIR} #{t.source}"
end

## -------------------------------------------------------------------
## Tasks

task :compile => [MIBS_DIR] + MIB_BINS
