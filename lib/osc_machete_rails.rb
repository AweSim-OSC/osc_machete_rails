require "osc/machete"
require "osc_machete_rails/engine"
require "osc_machete_rails/statusable"
require "osc_machete_rails/workflow"
require "osc_machete_rails/helper"

module OscMacheteRails
  mattr_accessor :update_status_of_all_active_jobs_on_each_request

  # make OSC::Machete::SimpleJob an alias of this module for backwards compatibility
  OSC::Machete::SimpleJob = self
end
