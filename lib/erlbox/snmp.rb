## -------------------------------------------------------------------
##
## Erlang Toolbox: Optional SNMP Tasks
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

desc "Compile SNMP MIBs"
task :snmp => [MIBS_DIR] + MIB_BINS

task :compile => :snmp
