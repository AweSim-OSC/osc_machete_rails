require 'rails/generators/rails/scaffold_controller/scaffold_controller_generator'

class OscMacheteRails::ScaffoldControllerGenerator < Rails::Generators::ScaffoldControllerGenerator
  source_root File.expand_path('../templates', __FILE__)

  attr_reader :job

  def initialize(args, *options)
    jobs = args.grep(/:jobs$/)
    args = args - jobs
    @job = Rails::Generators::GeneratedAttribute.parse(jobs.first || "job:jobs")

    super
  end

  # override ScaffoldControllerGenerator
  hook_for :template_engine

  # override ScaffoldControllerGenerator
  hook_for :helper, as: :scaffold do |invoked|
    invoke invoked, [ controller_name ]
  end

  # remove hook for jbuilder
  remove_hook_for :jbuilder
end
