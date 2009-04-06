## -------------------------------------------------------------------
##
## Erlang Toolbox: Optional tasks for building C extensions
## Copyright (c) 2008 The Hive.  All rights reserved.
##
## -------------------------------------------------------------------

if !defined?(APP_NAME)
  fail "You must require 'erlbox' before requiring this file"
end

## -------------------------------------------------------------------
## Constants

C_SRCS = FileList["c_src/*.c"]
C_OBJS = C_SRCS.pathmap("%X.o")
DRIVER = "priv/#{APP_NAME}_drv.so"

CLEAN.include %w( c_src/*.o priv/*.so  )

## -------------------------------------------------------------------
## Rules

directory 'c_src'

rule ".o" => ["%X.c", "%X.h"] do |t|
  puts "compiling #{t.source}..."
  sh "gcc -g -c -Wall -Werror -fPIC #{dflag} -Ic_src/system/include -I#{erts_dir()}/include #{t.source} -o #{t.name}"
end

file DRIVER => ['c_src'] + C_OBJS do
  puts "linking priv/#{DRIVER}..."
  sh "gcc -g #{erts_link_cflags()} c_src/*.o c_src/system/lib/libdb-*.a -o #{DRIVER}"
end

## -------------------------------------------------------------------
## Tasks

desc "Compile and link the C port driver"
task :driver => DRIVER

task :compile => :driver

## -------------------------------------------------------------------
## Helpers

def dflag()
  debug? ? "-DDEBUG" : ""
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
