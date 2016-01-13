module OscMacheteRails
  # Methods that deal with pbs batch job status management
  # within a Rails ActiveRecord model
  module Statusable
    extend Gem::Deprecate

    delegate :submitted?, :completed?, :failed?, :active?, to: :status

    def status=(s)
      super(s.nil? ? s : s.to_s)
    end

    # getter returns a Status value from CHAR or a Status value
    def status
      OSC::Machete::Status.new(super)
    end

    # delete the batch job and update status
    def stop(update: true)
      update(status: OSC::Machete::Status.failed) if status.active? && update
      job.delete
    end

    # Initialize the object
    def self.included(obj)
      # TODO: throw warning if we detect that pbsid, status, save,
      # etc. are not apart of this; i.e.
      # Rails.logger.warn if Module.constants.include?(:Rails) && (! obj.respond_to?(:pbsid))
      # etc.

      # Store job object info in a JSON column and replace old column methods
      if obj.column_names.include? 'job_cache'
        obj.store :job_cache, accessors: [ :script, :pbsid, :host ], coder: JSON
        delegate :script_name, to: :job
        define_method :job_path do
          job.path
        end
      else
        define_method(:job_cache) do
          {
            script: Pathname.new(job_path).join(script_name),
            pbsid: pbsid,
            host: nil
          }
        end
      end

      # in Rails ActiveRecord objects after loaded from the database,
      # update the status
      if obj.respond_to?(:after_find)
        obj.after_find do |simple_job|
          simple_job.update_status!
        end
      end

      # before we destroy ActiveRecord
      # we delete the batch job and the working directory
      if obj.respond_to?(:before_destroy)
        obj.before_destroy do |simple_job|
          simple_job.stop update: false
        end
      end
    end

    # Setter that accepts an OSC::Machete::Job instance
    #
    # @param [Job] new_job The Job object to be assigned to the Statusable instance.
    def job=(new_job)
      if self.has_attribute?(:job_cache)
        job_cache[:script] = new_job.script_path.to_s
        job_cache[:pbsid] = new_job.pbsid
        job_cache[:host] = new_job.host if new_job.respond_to?(:host)
      else
        self.script_name = new_job.script_name
        self.job_path = new_job.path.to_s
        self.pbsid = new_job.pbsid
      end
      self.status = new_job.status
    end

    # Returns associated OSC::Machete::Job instance
    def job
      OSC::Machete::Job.new(job_cache.symbolize_keys)
    end

    # Build the results validation method name from script_name attr
    # using ActiveSupport methods
    #
    # Call this using the Rails console to see what method you should implement
    # to support results validation for that job.
    #
    # @return [String] A string representing a validation method name from script_name attr
    # using ActiveSupport methods
    def results_validation_method_name
      File.basename(script_name, ".*").underscore.parameterize('_') + "_results_valid?"
    end

    # A hook that can be overidden with custom code
    # also looks for default validation methods for existing
    # WARNING: THIS USES ActiveSupport::Inflector methods underscore and parameterize
    #
    # @return [Boolean] true if the results script is present
    def results_valid?
      valid = true

      if self.respond_to? :script_name
        if self.respond_to?(results_validation_method_name)
          valid = self.send(results_validation_method_name)
        end
      end

      valid
    end

    #FIXME: should have a unit test for this!
    # job.update_status! will update and save object
    # if submitted? and ! completed? and status changed from previous state
    # force will cause status to update regardless of completion status,
    # redoing the validations. This way, if you are fixing validation methods
    # you can use the Rails console to update the status of a Workflow by doing this:
    #
    #     Container.last.jobs.each {|j| j.update_status!(force: true) }
    #
    # Or for a single statusable such as job:
    #
    #     job.update_status!(force: true)
    #
    # FIXME: should log whether a validation method was called or
    # throw a warning that no validation method was found (the one that would have been called)
    #
    # @param [Boolean, nil] force Force the update. (Default: false)
    def update_status!(force: false)
      # by default only update if its an active job
      if  (status.not_submitted? && pbsid) || status.active? || force

        # get the current status from the system
        current_status = job.status

        # if job is done, lets re-validate
        if current_status.completed? || current_status.failed?
          current_status = results_valid? ? OSC::Machete::Status.completed : OSC::Machete::Status.failed
        end

        if current_status != self.status || force
          self.status = current_status
          self.save
        end
      end
    end
  end
end
