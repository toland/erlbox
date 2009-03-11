## -------------------------------------------------------------------
##
## Erlang Toolbox: Project rakefile
## Copyright (c) 2008 The Hive.  All rights reserved.
##
## -------------------------------------------------------------------

require 'yaml'
require 'rake'
require 'rake/clean'
require 'rake/rdoctask'

RDOC_TITLE = "Erlang Toolbox documentation"

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name         = 'erlbox'
    s.platform     = Gem::Platform::RUBY
    s.author       = 'Phillip Toland'
    s.email        = 'ptoland@thehive.com'
    s.homepage     = 'http://thehive.com/'
    s.summary      = 'Erlang Toolbox'
    s.description  = 'Rake tasks and helper scripts for building Erlang applications.'
    s.require_path = 'lib'
    s.files        = ['README.txt', 'Rakefile'] + Dir['lib/**/*']

    s.rubyforge_project = 'erlbox'

    # rdoc
    s.has_rdoc         = true
    s.extra_rdoc_files = ['README.txt']
    s.rdoc_options     = ['--quiet', 
                          '--title', RDOC_TITLE,
                          '--opname', 'index.html',
                          '--main', 'README.txt']

    # Dependencies
    s.add_dependency 'rake', '>= 0.8.4'
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title = RDOC_TITLE
  rdoc.main = 'README.txt'
  rdoc.rdoc_files.include('README.txt')
end

task :default => :build
