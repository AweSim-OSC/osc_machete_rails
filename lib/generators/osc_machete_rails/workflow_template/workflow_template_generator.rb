class OscMacheteRails::WorkflowTemplateGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  argument :attributes, type: :array, default: [], banner: "field[:type][:index] field[:type][:index]"

  def copy_batch_script
    template "main.sh.mustache", "jobs/#{file_name}/main.sh.mustache"
  end
end
