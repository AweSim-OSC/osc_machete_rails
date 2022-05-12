$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "osc_machete_rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "osc_machete_rails"
  s.version     = OscMacheteRails::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Eric Franz"]
  s.email       = ["efranz@osc.edu"]
  s.homepage    = "https://github.com/OSC/osc_machete_rails"
  s.summary     = "Build Rails apps to manage batch jobs (currently OSC specific)"
  s.description = "Build Rails apps to manage batch jobs (currently OSC specific). Provides generators and a Rails plugin."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE.txt", "Rakefile", "README.md", "CHANGELOG.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 5.0", ">= 5.0.0"
  s.add_dependency "osc-machete", "~> 2.0"

  s.add_development_dependency "sqlite3", "~> 1.4"
  s.add_development_dependency "mocha"
  s.add_development_dependency "minitest"# , ">= 5.0"
  s.add_development_dependency "pbs", "~> 2.0"

  # dummy app needs these
  s.add_development_dependency "bootstrap_form", "~> 4.3.0"

  # needed for rails 5
  s.add_development_dependency 'rails-controller-testing'
  s.add_development_dependency 'listen'
  s.add_development_dependency 'bootsnap'
end
