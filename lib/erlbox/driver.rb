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
    %w(-fPIC -bundle -flat_namespace -undefined suppress)
  else
    %w(-fpic -shared)
  end
end

## -------------------------------------------------------------------
## Constants

C_SRCS = FileList["c_src/*.c"]
C_OBJS = C_SRCS.pathmap("%X.o")
CC_FLAGS = %W(-g -c -Wall -Werror -fPIC #{dflag()} -I#{erts_dir()}/include)
LD_FLAGS = erts_link_cflags()
DRIVER = "priv/#{APP_NAME}_drv.so"

CLEAN.include %w( c_src/*.o priv/*.so  )

## -------------------------------------------------------------------
## Rules

directory 'c_src'

rule ".o" => ["%X.c", "%X.h"] do |t|
  puts "compiling #{t.source}..."
  sh "gcc #{print_flags(CC_FLAGS)} #{t.source} -o #{t.name}"
end

file DRIVER => ['c_src'] + C_OBJS do
  puts "linking priv/#{DRIVER}..."
  sh "gcc -g #{print_flags(LD_FLAGS)} c_src/*.o -o #{DRIVER}"
end

## -------------------------------------------------------------------
## Tasks

desc "Compile and link the C port driver"
task :driver => DRIVER

task :compile => :driver
