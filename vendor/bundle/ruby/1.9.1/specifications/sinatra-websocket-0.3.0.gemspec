# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "sinatra-websocket"
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Caleb Crane"]
  s.date = "2013-04-03"
  s.description = "Makes it easy to upgrade any request to a websocket connection in Sinatra"
  s.email = "sinatra-websocket@simulacre.org"
  s.homepage = "http://github.com/simulacre/sinatra-websocket"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.25"
  s.summary = "Simple, upgradable WebSockets for Sinatra."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<eventmachine>, [">= 0"])
      s.add_runtime_dependency(%q<thin>, [">= 1.3.1"])
      s.add_runtime_dependency(%q<em-websocket>, ["~> 0.3.6"])
    else
      s.add_dependency(%q<eventmachine>, [">= 0"])
      s.add_dependency(%q<thin>, [">= 1.3.1"])
      s.add_dependency(%q<em-websocket>, ["~> 0.3.6"])
    end
  else
    s.add_dependency(%q<eventmachine>, [">= 0"])
    s.add_dependency(%q<thin>, [">= 1.3.1"])
    s.add_dependency(%q<em-websocket>, ["~> 0.3.6"])
  end
end
