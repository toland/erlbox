= Erlang Toolbox

== SYNOPSIS

This is a set of Rake tasks and scripts for working with Erlang projects.


== USAGE

The erlbox Rake tasks assume a certain directory structure. The tasks may or may
not work correctly if you do not follow the prescribed structure (most likely not).

    APP_ROOT
      |-- Rakefile
      |-- ebin
      |-- include
      |-- int_test
      |-- logs
      |-- mibs
      |-- perf_test
      |-- priv
      |-- src
      `-- unit_test

If you are on the golden path then all you need to do is put "require 'erlbox'"
at the top of an empty Rakefile. If you are on the golden path and have SNMP
mibs to compile then you can add "require 'erlbox/snmp'".

The behavior of erlbox can be customized by setting certain variables or by
"overriding" certain Rake tasks. For example, if you have other Erlang
applications that need to be on the Erlang path when you compile and run tests
then add them to the ERL_PATH variable:

    ERL_PATH.include %W( #{PWD}/../otherapp /usr/local/lib/erlang/alib )

The variables and constants (like ERL_PATH and PWD) are described in the
Reference section.

== REFERENCE

=== CONSTANTS

These constants are available for reference in your Rakefile, but their values
should not be changed. Dark and evil things will happen if you change them...

PWD::
    This constant contains the working directory when the Rakefile was invoked.

ERL_SRC::
    The list of Erlang sources to be compiled to beam files. This does not
    include test sources.

ERL_BEAM::
    The list of beam files that are produced from Erlang sources.

APP_FILE::
    The path to the app file for this application.

ERL_INCLUDE::
    The directory where *.hrl files live.

TEST_ROOT::
    The root of the test directory hierarchy.

TEST_LOG_DIR::
    The directory where test results are placed.

UNIT_TEST_DIR::
    The directory where unit tests are located.

INT_TEST_DIR::
    The directory where integration tests are located.

PERF_TEST_DIR::
    The directory where performance tests are located.


=== VARIABLES

These variables can be customized in your Rakefile to control the behavior of
the erlbox tasks.

ERL_PATH::
    A FileList with other Erlang applications that will be added to the command
    line for "erl" and "erlc" with "-pa" switches. Defaults to an empty list.

ERLC_FLAGS::
    An array of flags that will be passed to the "erlc" command. You may append
    flags to this list, but clearing it will cause the build to fail.

UNIT_TEST_FLAGS::
    A list of flags to be passed to the command that runs the unit tests.
    Defaults to an empty list.

INT_TEST_FLAGS::
    A list of flags to be passed to the command that runs the unit tests.
    Defaults to an empty list.

PERF_TEST_FLAGS::
    A list of flags to be passed to the command that runs the unit tests.
    Defaults to an empty list.

CLEAN and CLOBBER::
    These variables have their standard meaning from Rake.


=== TASKS

compile::
    Compile *.erl files to beam and *.mib files to bin. This is the default task.

rebuild::
    Run the clean task followed by the compile task.

package::
    Package the application into a form that is suitable for publishing to a faxien repo.

doc::
    Generate edoc documentation.

test:prepare::
    General test preparation that is run before all tests.

test:results::
    Open the test results in a browser (only on OS X).

test:all::
    Run the unit, integration and performance tests sequentially.

test, test:unit::
    Run the unit tests.

test:unit:prepare::
    Preparation that is run before unit tests.

test:unit:cover::
    Run the unit tests with coverage.

int_test, test:int::
    Run the integration tests.

test:int:prepare::
    Preparation that is run before integration tests.

test:int:cover::
    Run the integration tests with coverage.

perf_test, test:perf::
    Run the performance tests.

test:perf:prepare::
    Preparation that is run before performance tests.

test:perf:cover::
    Run the performance tests with coverage.


=== FUNCTIONS

These functions can be called from your Rakefile. Any erlbox functions that are
not listed here are considered private and should not be called.

append_flags(flags, value)::
    Append value to the flags constant. Example: "append_flags ERLC_FLAGS, '+debug'".

erl_run(script, args = "")
    Run the Erlang code in script optionally passing args.

erl_where(lib)
    Return the physical location of the specified Erlang library.

erl_app_version(app)
    Return the version of the Erlang application defined in the app file.


== REQUIREMENTS

If you want to use the doc task and you are using Faxien, you must install the
`edoc` and `syntax_tools` applications (`faxien ia <appname>`).

You need the current version of Rake to use the tasks (obviously). Nothing else
is required.

== INSTALL

Assuming you have checked out the Erlbox sources to a directory called 'erlbox',
all you need to do is:

  rake install

Be sure to enter your password when requested.

If you have not installed the jeweler gem you will need to do so:

  gem sources --add http://gems.github.com
  sudo gem install technicalpickles-jeweler

== HISTORY

=== 1.0 12/31/2008

* Initial release.


Copyright (c) 2008 The Hive
