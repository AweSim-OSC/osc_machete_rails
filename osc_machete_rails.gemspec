$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "osc_machete_rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "osc_machete_rails"
  s.version     = OscMacheteRails::VERSION
  s.authors     = ["Eric Franz"]
  s.email       = ["efranz@osc.edu"]
  s.homepage    = "http://www.awesim.org"
  s.summary     = "AweSim"
  s.description = "Rails backend for appkit."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.0"
  s.add_dependency "osc-machete", "~> 1.0.0.rc1"
  s.add_dependency "awesim_rails", "~> 1.0.0.rc1"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "mocha"
  s.add_development_dependency "minitest"# , ">= 5.0"

  # dummy app needs these
  s.add_development_dependency "bootstrap_form", "~> 2.3.0"
end
