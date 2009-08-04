# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{just_enumerable_stats}
  s.version = "0.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["David Richards"]
  s.date = %q{2009-08-04}
  s.default_executable = %q{jes}
  s.description = %q{Basic statistics on Ruby enumerables}
  s.email = %q{davidlamontrichards@gmail.com}
  s.executables = ["jes"]
  s.files = ["README.rdoc", "VERSION.yml", "bin/jes", "lib/fixed_range.rb", "lib/just_enumerable_stats", "lib/just_enumerable_stats/stats.rb", "lib/just_enumerable_stats.rb", "spec/fixed_range_spec.rb", "spec/just_enumerable_stats", "spec/just_enumerable_stats/stats_spec.rb", "spec/just_enumerable_stats_spec.rb", "spec/spec_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/davidrichards/just_enumerable_stats}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Basic statistics on Ruby enumerables}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
