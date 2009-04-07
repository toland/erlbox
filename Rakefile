## -------------------------------------------------------------------
##
## Erlang Toolbox: Project rakefile
## Copyright (c) 2008 The Hive.  All rights reserved.
##
## -------------------------------------------------------------------

require 'yaml'
require 'rake'
require 'rake/clean'

CLEAN.include 'pkg'

begin
  require 'jeweler'

  module Git
    class Lib
      def tag(tag)
        # Force an annotated tag
        command('tag', [tag, '-a', '-m', tag])
      end
    end
  end

  Jeweler::Tasks.new do |s|
    s.name         = 'erlbox'
    s.platform     = Gem::Platform::RUBY
    s.author       = 'Phillip Toland'
    s.email        = 'ptoland@thehive.com'
    s.homepage     = 'http://projects.rascal/projects/erlbox'
    s.summary      = 'Erlang Toolbox'
    s.description  = 'Rake tasks and helper scripts for building Erlang applications.'
    s.require_path = 'lib'
    s.has_rdoc     = false

    # Dependencies
    s.add_dependency 'rake', '>= 0.8.4'
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end

task :default => :build
