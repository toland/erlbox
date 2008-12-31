= Erlang Toolbox

== SYNOPSIS

This is a set of Rake tasks and scripts for working with Erlang projects.


== USAGE

`require erlbox` in your project Rakefile. If you are on the golden path this
should be all that is necessary.


== REQUIREMENTS

If you want to use the doc task and you are using Faxien, you must install the
`edoc` and `syntax_tools` applications (`faxien ia <appname>`).

You need the following gems to use the tasks.

* rake >= 0.83 (seriously, when is rake gonna hit 1.0?)

If you want to work with the client code, you will also need Rubygems version
1.2 or better and the following gems.

* rspec >= 1.1.4


== INSTALL

  sudo gem install /path/to/erlbox-<version>.gem

== HISTORY

=== 1.0 12/29/2008

* Initial release.


Copyright (c) 2008 The Hive
