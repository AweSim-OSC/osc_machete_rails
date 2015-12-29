class OscMacheteRails::ResourceRouteGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  # Properly nests namespaces passed into a generator
  #
  #   $ rails generate osc_machete_rails:workflow_route admin/users/products
  #
  # should give you
  #
  #   namespace :admin do
  #     namespace :users
  #       resources :products do
  #         member do
  #           put 'submit'
  #           put 'copy'
  #         end
  #       end
  #     end
  #   end
  def add_workflow_route
    return if options[:actions].present?

    # iterates over all namespaces and opens up blocks
    regular_class_path.each_with_index do |namespace, index|
      write("namespace :#{namespace} do", index + 1)
    end

    # inserts the primary resource
    write("resources :#{file_name.pluralize} do", route_length + 1)
    write("member do", route_length + 2)
    write("put 'submit'", route_length + 3)
    write("put 'copy'", route_length + 3)
    write("end", route_length + 2)
    write("end", route_length + 1)

    # ends blocks
    regular_class_path.each_index do |index|
      write("end", route_length - index)
    end

    # route prepends two spaces onto the front of the string that is passed, this corrects that
    route route_string[2..-1]
  end

  private
    def route_string
      @route_string ||= ""
    end

    def write(str, indent)
      route_string << "#{"  " * indent}#{str}\n"
    end

    def route_length
      regular_class_path.length
    end
end
