class OscMacheteRails::JobModelGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("../templates", __FILE__)

  def initialize(args, *options)
    args << 'status:string'
    args << 'pbsid:string'
    args << 'job_path:string'
    args << 'script_name:string'

    super
  end

  argument :attributes, type: :array, default: [], banner: "field[:type][:index] field[:type][:index]"
  hook_for :orm, required: true
end
