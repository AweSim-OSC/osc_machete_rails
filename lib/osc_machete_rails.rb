require "osc/machete"
require "osc_machete_rails/engine"
require "osc_machete_rails/submittable"
require "osc_machete_rails/statusable"
require "osc_machete_rails/workflow"
require "osc_machete_rails/helper"

module OscMacheteRails
  # Include the Submittable and Statusable modules by default when you include
  # this module
  #
  # FIXME: can we delete this? If this is not needed for backwards
  # compatibility...
  #
  # @param [Object] obj The base object.
  def self.included(obj)
    #HACK: we bypass the private visiblity of Module#include
    # for Ruby 2.0.0; in Ruby 2.1.0 Module#include is public
    # so this should be safe
    obj.send :include, OscMacheteRails::Submittable
    obj.send :include, OscMacheteRails::Statusable
  end

  # make OSC::Machete::SimpleJob an alias of this module for backwards
  # compatibility
  OSC::Machete::SimpleJob = self
end
