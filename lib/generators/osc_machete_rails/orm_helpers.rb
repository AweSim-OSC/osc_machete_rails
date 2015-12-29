module OscMacheteRails::OrmHelpers
  private
    def migration_template(source, destination, config = {})
      super 'migration.rb', destination, config
    end
end
