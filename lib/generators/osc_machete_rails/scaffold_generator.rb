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
  hook_for :workflow_model, type: :boolean

  # hook for job model/migration
  hook_for :job_model, type: :boolean do |model|
    new_args = orig_args.dup
    new_args[0] = "#{singular_table_name}_job"
    new_args << "#{singular_table_name}:references"
    invoke model, new_args
  end

  # override hook for adding config/routes
  hook_for :resource_route, required: true

  # hook for workflow batch script template
  hook_for :workflow_template, type: :boolean

  # override ScaffoldGenerator
  hook_for :scaffold_controller, required: true

  # remove scaffold_stylesheet
  remove_hook_for :stylesheet_engine
end
