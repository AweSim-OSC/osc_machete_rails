require 'rails/generators/rails/scaffold_controller/scaffold_controller_generator'

class OscMacheteRails::ScaffoldControllerGenerator < Rails::Generators::ScaffoldControllerGenerator
  source_root File.expand_path('../templates', __FILE__)

  # attribute to know what the job model is - see comments on active_record/workflow_model_generator.rb
  attr_reader :job

  def initialize(args, *options)
    jobs = args.grep(/:jobs$/)
    args = args - jobs
    @job = Rails::Generators::GeneratedAttribute.parse(jobs.first || "job:jobs")

    super
  end

  # override ScaffoldControllerGenerator
  # by recalling hook_for, the erb_generator will be searched for under OscMacheteRails
  # (idiosyncracy of Thor)
  #
  # the default template engine is erb, so we provide specific erb_generator.rb and its templates
  # see lib/generators/osc_machete_rails/erb for details
  hook_for :template_engine

  # remove hook for jbuilder to omit jbuilder files
  # TODO: if we want to support jbuilder, we need to remove this hook and fix the controller template
  # to optionally return json, which currently only assumes HTML; we might want the controller to still
  # handle json
  remove_hook_for :jbuilder
end
