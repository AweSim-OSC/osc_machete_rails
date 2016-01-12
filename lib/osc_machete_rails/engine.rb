module OscMacheteRails
  class Engine < ::Rails::Engine
    isolate_namespace OscMacheteRails

    config.app_generators do |g|
      g.workflow_model      true
      g.job_model           true
      g.workflow_template   true
    end

    config.before_initialize do
      OscMacheteRails.update_status_of_all_active_jobs_on_each_request = true
    end

    config.after_initialize do
      if OscMacheteRails.update_status_of_all_active_jobs_on_each_request
        # set before action on both Engine controllers and main App controllers
        # to update the status of all the active jobs
        ::ApplicationController.before_action -> { OSC::Machete::SimpleJob::Statusable.update_status_of_all_active_jobs }
        ApplicationController.before_action -> { OSC::Machete::SimpleJob::Statusable.update_status_of_all_active_jobs }
      end
    end
  end
end
