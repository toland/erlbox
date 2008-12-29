## -------------------------------------------------------------------
##
## Erlang Toolbox: ErlBox::VERSION constant
## Copyright (c) 2008 The Hive.  All rights reserved.
##
## -------------------------------------------------------------------

module ErlBox #:nodoc:
  module VERSION #:nodoc:
    def self.git_revision
      `git rev-list HEAD | wc -l`.strip
    end

    def self.make_revision
      revfile = File.dirname(__FILE__) + '/../../.revision'
      File.exist?(revfile) ? `cat #{revfile}`.strip : git_revision
    end

    # Used when the version is updated programmatically.
    def self.latest #:nodoc:
      [MAJOR, MINOR, git_revision].join('.')
    end

    MAJOR = 1
    MINOR = 0
    TINY  = make_revision

    STRING = [MAJOR, MINOR, TINY].join('.')
  end
end
