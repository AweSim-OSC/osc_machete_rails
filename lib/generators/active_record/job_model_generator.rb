require 'rails/generators/active_record/model/model_generator'
require 'generators/active_record/orm_helpers'

class ActiveRecord::JobModelGenerator < ActiveRecord::Generators::ModelGenerator
  include ActiveRecord::OrmHelpers
  source_root File.expand_path('../templates', __FILE__)

  # overrides original ModelGenerator#create_model_file to make a job_model instead of a model
  # since we are inheriting from ModelGenerator, we get the tests and all the other good stuff
  def create_model_file
    template 'job_model.rb', File.join('app/models', class_path, "#{file_name}.rb")
  end
end
