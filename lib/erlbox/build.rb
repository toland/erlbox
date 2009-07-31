## -------------------------------------------------------------------
##
## Erlang Toolbox: Included tasks for building Erlang sources
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

puts "WARNING: Debugging is enabled." if debug?

## -------------------------------------------------------------------
## Constants

PWD = Dir.getwd

ERL_SRC = FileList['src/**/*.erl']
ERL_BEAM = ERL_SRC.pathmap("%{src,ebin}X.beam")
ERL_PATH = FileList.new
APP_FILE = FileList["#{PWD}/ebin/*.app"][0]
APP_NAME = File.basename(APP_FILE, ".app")

unless APP_FILE && File.exists?(APP_FILE)
  fail "ERROR: No app file found."
end

ERL_INCLUDE = "./include"
ERLC_FLAGS = %W( -I#{ERL_INCLUDE} -W )
ERLC_FLAGS << '+debug_info' if debug?

CLEAN.include %w( **/*.beam **/erl_crash.dump )

## -------------------------------------------------------------------
## Rules

directory 'ebin'

rule(%r(^ebin/.*\.beam$) => ["%{ebin,src}X.erl"]) do |t|
  puts "compiling #{t.source}..."
  sh "erlc #{print_flags(ERLC_FLAGS)} #{expand_path(ERL_PATH)} -o ebin #{t.source}", :verbose => verbose?
end

## -------------------------------------------------------------------
## Tasks

namespace :build do

  desc "Verify that all application modules are listed in the app file"
  task :validate_app do
    # Setup app name and build sets of modules from the .app as well as
    # beams that got compiled
    modules = Set.new(erl_app_modules(APP_NAME))
    beams = Set.new(ERL_BEAM.pathmap("%n").to_a)

    puts "validating #{APP_NAME}.app..."

    # Identify .beam files which are listed in the .app, but not present in ebin/
    missing_beams = (modules - beams)
    if not missing_beams.empty?
      msg = "One or more modules listed in #{APP_NAME}.app do not exist as .beam:\n"
      missing_beams.each { |m| msg << " * #{m}\n" }
      fail msg
    end

    # Identify modules which are not listed in the .app, but are present in ebin/
    missing_modules = (beams - modules)
    if not missing_modules.empty?
      msg = "One or more .beam files exist that are not listed in #{APP_NAME}.app:\n"
      missing_modules.each { |m| msg << "  * #{m}\n" }
      fail msg
    end
  end

  desc "Compile Erlang sources to .beam files"
  task :compile => ['ebin'] + ERL_BEAM + [:validate_app]

  desc "Do a fresh build from scratch"
  task :rebuild => [:clean, :compile]

end

task :compile => 'build:compile'
task :default => [:compile]
