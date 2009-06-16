## -------------------------------------------------------------------
##
## Erlang Toolbox: Optional tasks for building C extensions
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

def ei_dir()
  script = <<-ERL
      io:format("~s\n", [code:lib_dir(erl_interface)])
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

CC_FLAGS = %W(-g -c -Wall -fno-common #{dflag()} -I#{SRC_DIR} -I#{erts_dir()}/include -I#{ei_dir()}/include)
LD_FLAGS = erts_link_cflags()
EI_LIBS  = %W(-L#{ei_dir()}/lib -lerl_interface -lei)
LD_LIBS  = EI_LIBS

CLEAN.include %W( #{SRC_DIR}/*.o #{DRV_DIR}/*.so  )

## -------------------------------------------------------------------
## Rules

directory SRC_DIR
directory DRV_DIR

rule ".o" => ["%X.c", "%X.h"] do |t|
  puts "compiling #{t.source}..."
  sh "gcc #{print_flags(CC_FLAGS)} #{t.source} -o #{t.name}", :verbose => verbose?
end

file DRIVER => [SRC_DIR, DRV_DIR] + C_OBJS do
  puts "linking #{DRIVER}..."
  sh "gcc -g #{print_flags(LD_FLAGS)} #{C_OBJS.join(' ')} #{print_flags(LD_LIBS)} -o #{DRIVER}", :verbose => verbose?
end

## -------------------------------------------------------------------
## Tasks

desc "Compile and link the C port driver"
task :driver => DRIVER

task :compile => :driver
