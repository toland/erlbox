## -------------------------------------------------------------------
##
## Erlang Toolbox: OTP release tasks
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
require 'rake/clean'
include FileUtils

if !defined?(REL_APPNAME)
  fail "The variable REL_APPNAME must be defined"
end

verbose false

CLEAN.include FileList["#{REL_APPNAME}*"]

REL_APPS = %w( runtime_tools )
REL_VERSION  = `cat vers/#{REL_APPNAME}.version`.strip
REL_FULLNAME = "#{REL_APPNAME}-#{REL_VERSION}"

ERTS_VSN = `scripts/get-erts-vsn`.strip

directory REL_APPNAME


task :build_app do
  cd "../apps" do
    sh "rake"
  end
end

desc "Run the make-rel script"
task :make_rel do
  sh "scripts/make-rel #{REL_APPNAME} #{REL_VERSION} #{REL_APPS.join(' ')}"
end

task :prepare => [REL_APPNAME, :make_rel] do
  sh "tar -xzf #{REL_FULLNAME}.tar.gz -C #{REL_APPNAME}"
  rm "#{REL_FULLNAME}.tar.gz"

  sh %Q(echo "#{ERTS_VSN} #{REL_VERSION}" > #{REL_APPNAME}/releases/start_erl.data)
  cp_r Dir.glob("overlays/#{REL_APPNAME}/*"), REL_APPNAME
end

desc "Stage the application into a directory"
task :stage => [:clean, :build_app, :prepare]

desc "Create a tarball from the staged application"
task :release => :stage do
  mv REL_APPNAME, REL_FULLNAME
  sh "tar -cjf #{REL_FULLNAME}-#{RUBY_PLATFORM}.tar.bz2 #{REL_FULLNAME}"
  rm_rf REL_FULLNAME
end
