# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "osc-ruby"
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Colin Harris"]
  s.date = "2013-05-04"
  s.description = "This OSC gem originally created by Tadayoshi Funaba has been updated for ruby 2.0/1.9/JRuby compatibility"
  s.email = "qzzzq1@gmail.com"
  s.homepage = "http://github.com/aberant/osc-ruby"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.25"
  s.summary = "a ruby client for the OSC protocol"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end
