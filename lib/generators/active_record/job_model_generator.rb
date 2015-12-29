require 'rails/generators/active_record/model/model_generator'
require 'generators/osc_machete_rails/orm_helpers'

class ActiveRecord::JobModelGenerator < ActiveRecord::Generators::ModelGenerator
  include OscMacheteRails::OrmHelpers
  source_root File.expand_path('../templates', __FILE__)

  def create_model_file
    template 'job_model.rb', File.join('app/models', class_path, "#{file_name}.rb")
  end
end
