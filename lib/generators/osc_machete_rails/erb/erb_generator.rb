require 'rails/generators/erb/scaffold/scaffold_generator'

class OscMacheteRails::ErbGenerator < Erb::Generators::ScaffoldGenerator
  source_root File.expand_path('../templates', __FILE__)
end
