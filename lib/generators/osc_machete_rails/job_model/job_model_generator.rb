class OscMacheteRails::JobModelGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("../templates", __FILE__)

  def initialize(args, *options)
    args |= %w(status:string)
    args |= %w(job_cache:text)

    super
  end

  argument :attributes, type: :array, default: [], banner: "field[:type][:index] field[:type][:index]"
  hook_for :orm, required: true
end
