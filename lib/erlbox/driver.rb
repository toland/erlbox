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

SRC_DIR = 'c_src'
C_SRCS  = FileList["#{SRC_DIR}/*.c"]
C_OBJS  = C_SRCS.pathmap("%X.o")

DRV_DIR = 'priv'
DRIVER  = "#{DRV_DIR}/#{APP_NAME}_drv.so"

CC_FLAGS = %W(-g -c -Wall -Werror -fPIC #{dflag()} -I#{erts_dir()}/include)
LD_FLAGS = erts_link_cflags()

CLEAN.include %W( #{SRC_DIR}/*.o #{DRV_DIR}/*.so  )

## -------------------------------------------------------------------
## Rules

directory SRC_DIR
directory DRV_DIR

rule ".o" => ["%X.c", "%X.h"] do |t|
  puts "compiling #{t.source}..."
  sh "gcc #{print_flags(CC_FLAGS)} #{t.source} -o #{t.name}"
end

file DRIVER => [SRC_DIR, DRV_DIR] + C_OBJS do
  puts "linking #{DRIVER}..."
  sh "gcc -g #{print_flags(LD_FLAGS)} #{SRC_DIR}/*.o -o #{DRIVER}"
end

## -------------------------------------------------------------------
## Tasks

desc "Compile and link the C port driver"
task :driver => DRIVER

task :compile => :driver
