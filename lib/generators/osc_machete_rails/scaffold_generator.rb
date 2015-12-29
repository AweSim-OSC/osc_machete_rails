require 'rails/generators/rails/scaffold/scaffold_generator'

class OscMacheteRails::ScaffoldGenerator < Rails::Generators::ScaffoldGenerator
  source_root File.expand_path('../templates', __FILE__)

  attr_reader :orig_args

  def initialize(args, *options)
    @orig_args = args
    super
  end

  # override ModelGenerator
  remove_hook_for :orm

  # hook for workflow model/migration
  hook_for :workflow_model, type: :boolean do |model|
    invoke model, orig_args + add_jobs
  end

  # hook for job model/migration
  hook_for :job_model, type: :boolean do |model|
    new_args = orig_args.dup
    new_args[0] = jobs_table_name
    new_args << "#{singular_table_name}:references"
    invoke model, new_args
  end

  # override hook for adding config/routes
  hook_for :resource_route, required: true

  # hook for workflow batch script template
  hook_for :workflow_template, type: :boolean

  # override ScaffoldGenerator
  hook_for :scaffold_controller, required: true do |controller|
    invoke controller, orig_args + add_jobs
  end

  # remove scaffold_stylesheet
  remove_hook_for :stylesheet_engine

  private
    def add_jobs
      ["#{jobs_table_name}:jobs"]
    end

    def jobs_table_name
      "#{singular_table_name}_job"
    end
end
