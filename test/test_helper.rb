# Configure Rails Environment
ENV["RAILS_ENV"] = "test"
ENV["RAILS_DATAROOT"] = "/dev/null"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

# dependencies that dummy app depends on
require "bootstrap_form"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# install the rails 5 gem
require 'rails-controller-testing'
Rails::Controller::Testing.install

# Load fixtures from the engine
if ActiveSupport::TestCase.method_defined?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
end
