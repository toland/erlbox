## -------------------------------------------------------------------
##
## Erlang Toolbox: OTP release tasks
## Copyright (c) 2008 The Hive.  All rights reserved.
##
## -------------------------------------------------------------------
require 'rake/clean'
include FileUtils

if !defined?(REL_APPNAME)
  fail "The variable REL_APPNAME must be defined"
end

CLEAN.include FileList["#{REL_APPNAME}*"]

REL_APPS = %w( runtime_tools )
REL_VERSION  = `cat vers/#{REL_APPNAME}.version`.strip
REL_FULLNAME = "#{REL_APPNAME}-#{REL_VERSION}"

ERTS_VSN = `scripts/get-erts-vsn`.strip

directory REL_APPNAME


task :build_app do
  cd "../apps" do
    sh "rake", :verbose => false
  end
end

task :prepare => REL_APPNAME do
  sh "scripts/make-rel #{REL_APPNAME} #{REL_VERSION} #{REL_APPS.join(' ')}"
  sh "tar -xzf #{REL_FULLNAME}.tar.gz -C #{REL_APPNAME}"
  rm "#{REL_FULLNAME}.tar.gz"

  sh %Q(echo "#{ERTS_VSN} #{REL_VERSION}" > #{REL_APPNAME}/releases/start_erl.data)
  cp_r Dir.glob("overlays/#{REL_APPNAME}/*"), REL_APPNAME
end

task :stage => [:clean, :build_app, :prepare]

task :release => :stage do
  mv REL_APPNAME, REL_FULLNAME
  sh "tar -cjf #{REL_FULLNAME}-#{RUBY_PLATFORM}.tar.bz2 #{REL_FULLNAME}"
  rm_rf REL_FULLNAME
end
