# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "omniauth-nate/version"

Gem::Specification.new do |s|
  s.name        = "omniauth-nate"
  s.version     = Omniauth::Nate::VERSION
  s.authors     = ["Junegunn Choi"]
  s.email       = ["junegunn.c@gmail.com"]
  s.homepage    = "https://github.com/junegunn/omniauth-nate"
  s.summary     = %q{OmniAuth strategy for nate.com}
  s.description = %q{OmniAuth strategy for nate.com (Korean web portal site which is a conglomerate of Nate, Cyworld and Empas)}

  s.rubyforge_project = "omniauth-nate"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_development_dependency "rack-test"
  s.add_development_dependency "mocha"
  s.add_development_dependency "webmock"
  s.add_runtime_dependency "omniauth-oauth", "~> 1.0"
  s.add_runtime_dependency "multi_json"
  s.add_runtime_dependency "insensitive_hash", ">= 0.1.0"
end
