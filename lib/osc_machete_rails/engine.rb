module OscMacheteRails
  class Engine < ::Rails::Engine
    isolate_namespace OscMacheteRails

    config.app_generators do |g|
      g.workflow_model      true
      g.job_model           true
      g.workflow_template   true
    end
  end
end
