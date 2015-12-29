class OscMacheteRails::WorkflowModelGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("../templates", __FILE__)

  def initialize(args, *options)
    args |= %w(staged_dir:string)

    super
  end

  argument :attributes, type: :array, default: [], banner: "field[:type][:index] field[:type][:index]"
  hook_for :orm, required: true
end
