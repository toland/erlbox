Gem::Specification.new do |s|
  s.name = %q{erlbox}
  s.version = "1.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Phillip Toland"]
  s.date = %q{2009-02-02}
  s.description = %q{Rake tasks and helper scripts for building Erlang applications.}
  s.email = %q{ptoland@thehive.com}
  s.extra_rdoc_files = ["README.txt"]
  s.files = ["README.txt", "Rakefile", "lib/erlbox", "lib/erlbox/recurse.rb", "lib/erlbox/release.rb", "lib/erlbox/snmp.rb", "lib/erlbox/utils.rb", "lib/erlbox.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://thehive.com/}
  s.rdoc_options = ["--quiet", "--title", "Erlang Toolbox documentation", "--opname", "index.html", "--main", "README.txt", "--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{erlbox}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{Erlang Toolbox}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_runtime_dependency(%q<rake>, [">= 0.8.3"])
    else
      s.add_dependency(%q<rake>, [">= 0.8.3"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0.8.3"])
  end
end
