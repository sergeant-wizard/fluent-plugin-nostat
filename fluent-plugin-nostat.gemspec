# -*- encoding: utf-8 -*-
# stub: fluent-plugin-nostat 0.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "fluent-plugin-nostat"
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["No JinHo"]
  s.date = "2016-03-15"
  s.email = "nozino@gmail.com"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    "Gemfile",
    "LICENSE.txt",
    "README.md",
    "AUTHORS",
    "fluent-plugin-nostat.gemspec",
    "lib/fluent/plugin/in_nostat.rb",
  ]
  s.homepage = "http://github.com/nozino/fluent-plugin-nostat"
  s.rubygems_version = "2.4.5"
  s.summary = "Linux Resource Monitoring Input plugin for Fluent event collector"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<fluent-mixin-rewrite-tag-name>, [">= 0"])
      s.add_runtime_dependency(%q<fluentd>, [">= 0.10.7", "< 2"])
      s.add_runtime_dependency(%q<rdoc>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
    else
      s.add_runtime_dependency(%q<fluent-mixin-rewrite-tag-name>, [">= 0"])
      s.add_runtime_dependency(%q<fluentd>, [">= 0.10.7", "< 2"])
      s.add_runtime_dependency(%q<rdoc>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.0"])
    end
  else
    s.add_runtime_dependency(%q<fluent-mixin-rewrite-tag-name>, [">= 0"])
    s.add_runtime_dependency(%q<fluentd>, [">= 0.10.7", "< 2"])
    s.add_runtime_dependency(%q<rdoc>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.0"])
  end
end