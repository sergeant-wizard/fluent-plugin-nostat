# -*- encoding: utf-8 -*-
# stub: fluent-plugin-nostat 0.2.1 ruby lib

Gem::Specification.new do |s|
  s.name = "fluent-plugin-nostat"
  s.version = "0.2.1"

  s.require_paths = ["lib"]
  s.authors = ["No JinHo"]
  s.email = "nozino@gmail.com"
  s.files = [
    "Gemfile",
    "LICENSE.txt",
    "README.md",
    "AUTHORS",
    "fluent-plugin-nostat.gemspec",
    "lib/fluent/plugin/in_nostat.rb",
  ]
  s.homepage = "http://github.com/nozino/fluent-plugin-nostat"
  s.description = "Linux Resource Monitoring Input plugin for Fluent event collector"
  s.summary = s.description

  s.add_runtime_dependency "fluentd", [">= 0.10.7", "< 2"]
end
