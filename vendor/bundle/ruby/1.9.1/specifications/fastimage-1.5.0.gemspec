# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "fastimage"
  s.version = "1.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Stephen Sykes"]
  s.date = "2013-07-02"
  s.description = "FastImage finds the size or type of an image given its uri by fetching as little as needed."
  s.email = "sdsykes@gmail.com"
  s.extra_rdoc_files = ["README.textile"]
  s.files = ["README.textile"]
  s.homepage = "http://github.com/sdsykes/fastimage"
  s.licenses = ["MIT"]
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.25"
  s.summary = "FastImage - Image info fast"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
