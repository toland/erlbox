# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{erlbox}
  s.version = "1.4.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Phillip Toland"]
  s.date = %q{2009-05-04}
  s.description = %q{Rake tasks and helper scripts for building Erlang applications.}
  s.email = %q{ptoland@thehive.com}
  s.extra_rdoc_files = [
    "README.txt"
  ]
  s.files = [
    "README.txt",
    "Rakefile",
    "VERSION.yml",
    "lib/erlbox.rb",
    "lib/erlbox/build.rb",
    "lib/erlbox/dialyzer.rb",
    "lib/erlbox/driver.rb",
    "lib/erlbox/edoc.rb",
    "lib/erlbox/faxien.rb",
    "lib/erlbox/recurse.rb",
    "lib/erlbox/release.rb",
    "lib/erlbox/snmp.rb",
    "lib/erlbox/test.rb",
    "lib/erlbox/utils.rb"
  ]
  s.homepage = %q{http://projects.rascal/projects/erlbox}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.2}
  s.summary = %q{Erlang Toolbox}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rake>, [">= 0.8.4"])
    else
      s.add_dependency(%q<rake>, [">= 0.8.4"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0.8.4"])
  end
end
