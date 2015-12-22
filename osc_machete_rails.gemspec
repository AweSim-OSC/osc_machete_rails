$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "osc_machete_rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "osc_machete_rails"
  s.version     = OscMacheteRails::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of OscMacheteRails."
  s.description = "TODO: Description of OscMacheteRails."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.0"
  # TODO: uncomment after removing gem line in Gemfile
  # s.add_dependency "osc-machete", "~> 1.0.0.pre1"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "mocha"
  s.add_development_dependency "minitest"# , ">= 5.0"
end
