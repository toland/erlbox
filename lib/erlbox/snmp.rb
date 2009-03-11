## -------------------------------------------------------------------
##
## Erlang Toolbox: SNMP Tasks
## Copyright (c) 2008 The Hive.  All rights reserved.
##
## -------------------------------------------------------------------

MIB_SRCS = FileList["mibs/*.mib"]
MIB_BINS = MIB_SRCS.pathmap("%{mibs,priv/mibs}X.bin")

directory 'priv/mibs'

CLEAN.include %w( priv/mibs )

rule ".bin" => ["%{priv/mibs,mibs}X.mib"] do |t|
  puts "compiling #{t.source}..."
  sh "erlc -I priv/mibs -o priv/mibs #{t.source}"
end

desc "Compile SNMP mibs to .bin files"
task :compile_mibs => ['priv/mibs'] + MIB_BINS

task :compile => [:compile_mibs]
