---
layout: default
title: Erlbox - The Erlang Toolbox
---


This is a set of Rake tasks and scripts for working with Erlang projects.

### USAGE

The erlbox Rake tasks assume a certain directory structure. The tasks may or may
not work correctly if you do not follow the prescribed structure (most likely
not).

    APP_ROOT
      |-- Rakefile
      |-- ebin
      |-- include
      |-- int_test
      |-- logs
      |-- mibs
      |-- priv
      |-- src
      `-- test

If you are on the golden path then all you need to do is put `require 'erlbox'`
at the top of an empty Rakefile. There are a few optional modules that you may
take advantage of by requiring the appropriate file in your Rakefile. For
example, if you are on the golden path and have SNMP mibs to compile then you
can add `require 'erlbox/snmp'`.

The behavior of erlbox can be customized by setting certain variables or by
extending Rake tasks. For example, if you have other Erlang applications that
need to be on the Erlang path when you compile and run tests then add them to
the `ERL_PATH` variable:

{% highlight ruby %}
ERL_PATH.include %W( #{PWD}/../otherapp /usr/local/lib/erlang/alib )
{% endhighlight %}

The variables and constants (like `ERL_PATH` and `PWD`) are described in the
Reference section.

You can see what tasks are available by issuing the command `rake -T`.


### DEFAULT FUNCTIONALITY

This section describes the features that are included by default. All of the
tasks described here are available after requiring 'erlbox'.

#### Compiling Erlang sources

The most basic Erlbox feature is compiling Erlang sources to beam files. The
sources are found in the `src` directory (not subdirectories) and the beam files
are placed in the `ebin` directory. After compilation is complete Erlbox will
validate that all of the compiled modules are listed in the app file.

The flags passed to the `erlc` compiler can be controlled via the `ERLC_FLAGS`
variable. `ERLC_FLAGS` will include `+debg_info` if you include `debug=1` on the
command line. 

All compilation tasks are in the "build" namespace.

 * `build:compile` or `compile`
 * `build:rebuild`
 * `build:validate_app` 

The `build:compile` task is the default. It will be executed if you type `rake`
with no task name.


#### Running tests

Test tasks are in the "test" namespace.

 * `test:prepare`
 * `test:unit` or `test`
 * `test:unit:prepare`
 * `test:unit:cover`
 * `test:int` or `int_test`
 * `test:int:prepare`
 * `test:int:cover`
 * `test:perf` or `perf_test`
 * `test:perf:prepare`
 * `test:perf:cover`


#### Generating documentation

Edoc generation tasks are in the "edoc" namespace.

* `edoc:run` or `edoc`


#### Publishing Faxien packages

Faxien tasks are in the "faxien" namespace.

 * `faxien:prepare`
 * `faxien:package`
 * `faxien:publish`

The `faxien` task is equivalent to executing `faxien:package` followed by
`faxien:publish`.


#### Running Dialyzer

To use Dialyzer with Erlbox, you must first ensure that you have a PLT file that
has information on all of the appropriate libraries. First, in your project
Rakefile, add any libraries that your code directly depends on to the `PLT_LIBS`
variable:

{% highlight ruby %}
PLT_LIBS << 'crypto' << 'inets' << 'mochiweb'
{% endhighlight %}

Note that `PLT_LIBS` contains kernel and stdlib by default.

Next, run the `dialyzer:update_plt` task. This will create a PLT file at
`~/.dialyzer_plt` if it does not already exist and it will add information for
the libraries listed in `PLT_LIBS`. It will also add information for any
applications listed in the `ERL_PATH` variable.

Finally, you can run Dialyzer using the `dialyzer` or `dialyzer:run` tasks.

The Dialyzer tasks are in the "dialyzer" namespace.

 * `dialyzer:update_plt`
 * `dialyzer:prepare`
 * `dialyzer:run` or `dialyzer`


### OPTIONAL FEATURES

Optional features are enabled by requiring an Erlbox extension module.

#### Compiling SNMP MIBs

Include support for compiling SNMP MIBs with 'erlbox/snmp':

{% highlight ruby %}
require 'erlbox/snmp'
{% endhighlight %}

The snmp module extends the `build:compile` task to also compile any SNMP MIBs.

If the default order for building the MIBs is wrong, override with a file line

{% highlight ruby %}
file 'priv/mibs/ENODE-MIB.bin' => 'priv/mibs/HCNUM-TC.bin'
{% endhighlight %}

#### Building a port driver

Include support for compiling a C port driver with 'erlbox/driver':

{% highlight ruby %}
require 'erlbox/driver'
{% endhighlight %}

The driver module extends the `build:compile` task to also compile any C source
files.


### REFERENCE

#### Constants

These constants are available for reference in your Rakefile, but their values
should not be changed. Dark and evil things will happen if you change them...

<dl>
  <dt>PWD</dt>
  <dd>This constant contains the working directory when the Rakefile was invoked.</dd>

  <dt>ERL_SRC</dt>
  <dd>The list of Erlang sources to be compiled to beam files. This does not include test sources.</dd>

  <dt>ERL_BEAM</dt>
  <dd>The list of beam files that are produced from Erlang sources.</dd>

  <dt>APP_FILE</dt>
  <dd>The path to the app file for this application.</dd>

  <dt>ERL_INCLUDE</dt>
  <dd>The directory where Erlang include (hrl) files live.</dd>

  <dt>TEST_ROOT</dt>
  <dd>The root of the test directory hierarchy.</dd>

  <dt>TEST_LOG_DIR</dt>
  <dd>The directory where test results are placed.</dd>

  <dt>UNIT_TEST_DIR</dt>
  <dd>The directory where unit tests are located.</dd>

  <dt>INT_TEST_DIR</dt>
  <dd>The directory where integration tests are located.</dd>

  <dt>PERF_TEST_DIR</dt>
  <dd>The directory where performance tests are located.</dd>
</dl>


#### Variables

These variables can be customized in your Rakefile to control the behavior of
the erlbox tasks.

<dl>
  <dt>ERL_PATH</dt>
  <dd>A FileList with other Erlang applications that will be added to the command line for "erl" and "erlc" with "-pa" switches. Defaults to an empty list.</dd>

  <dt>ERLC_FLAGS</dt>
  <dd>An array of flags that will be passed to the "erlc" command. You may append flags to this list, but clearing it will cause the build to fail.</dd>

  <dt>UNIT_TEST_FLAGS</dt>
  <dd>A list of flags to be passed to the command that runs the unit tests. Defaults to an empty list.</dd>

  <dt>INT_TEST_FLAGS</dt>
  <dd>A list of flags to be passed to the command that runs the integration tests. Defaults to an empty list.</dd>

  <dt>PERF_TEST_FLAGS</dt>
  <dd>A list of flags to be passed to the command that runs the performance tests. Defaults to an empty list.</dd>

  <dt>CLEAN and CLOBBER</dt>
  <dd>These variables have their standard meaning from Rake.</dd>
</dl>


#### Functions

These functions can be called from your Rakefile. Any erlbox functions that are
not listed here are considered private and should not be called.

<dl>
  <dt>append_flags(flags, value)</dt>
  <dd>Append value to the flags constant. Example: "append_flags ERLC_FLAGS, '+debug'".</dd>

  <dt>erl_run(script, args = "")</dt>
  <dd>Run the Erlang code in script optionally passing args.</dd>

  <dt>erl_where(lib, dir = 'include')</dt>
  <dd>Return the physical location of the specified Erlang library.</dd>

  <dt>erl_app_version(app)</dt>
  <dd>Return the version of the Erlang application defined in the app file.</dd>
</dl>


### REQUIREMENTS

If you want to use the `edoc` task and you are using Faxien, you must install the
`edoc` and `syntax_tools` applications (`faxien ia <appname>`).

You need the current version of Rake to use the tasks (obviously). Nothing else
is required.


### INSTALL

The gem can be installed directly from wax:

    sudo gem install erlbox --source=http://wax.hive/gems

Alternatively, if you have checked out the Erlbox sources to a directory called
'erlbox', all you need to do is:

    rake install

Be sure to enter your password when requested.
