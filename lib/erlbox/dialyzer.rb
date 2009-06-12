## -------------------------------------------------------------------
##
## Erlang Toolbox: Included tasks for running Dialyzer
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
require 'pathname'

## -------------------------------------------------------------------
## Constants

PLT_LIBS = %w( kernel stdlib )
PLT_FILE = "#{ENV['HOME']}/.dialyzer_plt"

CLEAN.include 'dialyzer.log'

## -------------------------------------------------------------------
## Rules

rule PLT_FILE do
  puts "generating base PLT file..."
  `dialyzer --build_plt -r #{erl_where('kernel', 'ebin')} --plt #{PLT_FILE}`
end

## -------------------------------------------------------------------
## Tasks

namespace :dialyzer do

  desc "Update your PLT file with the libraries required by this application"
  task :update_plt => PLT_FILE do
    PLT_LIBS.each do |lib|
      puts "adding #{lib} to plt..."
      `dialyzer --add_to_plt -r #{erl_where(lib, 'ebin')} --plt #{PLT_FILE}`
    end

    ERL_PATH.each do |app_path|
      path = abspath(app_path)
      puts "adding #{path} to plt..."
      `dialyzer --add_to_plt -r #{path} --plt #{PLT_FILE}`
    end
  end

  task :prepare do
    ERLC_FLAGS << '+debug_info'
  end

  desc "Run Dialyzer on the compiled beam files"
  task :run => [:prepare] + ERL_BEAM do
    warnings = ENV['WARN']
    if !warnings.nil? && !warnings.empty?
      warn_opts = ' -W' + warnings.split(',').join(' -W')
    else
      warn_opts = ''
    end

    sh "dialyzer -Iinclude -r ebin --plt #{PLT_FILE}\
                 -Werror_handling -Wunmatched_returns #{warn_opts} | tee dialyzer.log"
  end

end

task :dialyzer => 'dialyzer:run'
