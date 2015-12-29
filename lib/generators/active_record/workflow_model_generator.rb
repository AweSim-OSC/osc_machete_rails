require 'rails/generators/active_record/model/model_generator'
require 'generators/osc_machete_rails/orm_helpers'

class ActiveRecord::WorkflowModelGenerator < ActiveRecord::Generators::ModelGenerator
  include OscMacheteRails::OrmHelpers
  source_root File.expand_path('../templates', __FILE__)

  attr_reader :job

  def initialize(args, *options)
    jobs = args.grep(/:jobs$/)
    args = args - jobs
    @job = Rails::Generators::GeneratedAttribute.parse(jobs.first || "job:jobs")

    super
  end

  def create_model_file
    template 'workflow_model.rb', File.join('app/models', class_path, "#{file_name}.rb")
  end
end
