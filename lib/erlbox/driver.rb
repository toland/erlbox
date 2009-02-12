## -------------------------------------------------------------------
##
## Erlang Toolbox: Tasks for building C extensions
## Copyright (c) 2008 The Hive.  All rights reserved.
##
## -------------------------------------------------------------------
require 'erlbox'
require 'erlbox/utils'

C_SRCS = FileList["c_src/*.c"]
C_OBJS = C_SRCS.pathmap("%X.o")
DRIVER = "priv/#{erl_app_name(APP_FILE)}_drv.so"

directory 'c_src'

CLEAN.include %w( c_src/*.o priv/*.so  )

task :compile => [DRIVER]
task :compile_c => ['c_src'] + C_OBJS

rule ".o" => ["%X.c", "%X.h"] do |t|
  puts "compiling #{t.source}..."
  sh "gcc -g -c -Wall -Werror -fPIC #{dflag} -Ic_src/system/include -I#{erts_dir()}/include #{t.source} -o #{t.name}", :verbose => false
end

file DRIVER => [:compile_c] do
  puts "linking priv/#{DRIVER}..."
  sh "gcc -g #{erts_link_cflags()} c_src/*.o c_src/system/lib/libdb-*.a -o #{DRIVER}", :verbose => false
end

def dflag()
  ENV["release"] ? "" : "-DDEBUG"
end

def erts_dir()
  script = <<-ERL
      io:format("~s\n", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version)])])
      ERL
  erl_run(script)
end

def erts_link_cflags()
  if darwin?
    " -fPIC -bundle -flat_namespace -undefined suppress "
  else
    " -fpic -shared"
  end
end

