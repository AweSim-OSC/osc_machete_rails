module OscMacheteRails
  # Methods that deal with pbs batch job status management
  # within a Rails ActiveRecord model
  module Statusable


    delegate :submitted?, :completed?, :passed?, :failed?, :active?, to: :status

    def status=(s)
      super(OSC::Machete::Status.new(s).char)
    end

    # getter returns a Status value from CHAR or a Status value
    def status
      OSC::Machete::Status.new(super)
    end

    # delete the batch job and update status
    # may raise PBS::Error as it is unhandled here!
    def stop(update: true)
      return unless status.active?

      job.delete
      update(status: OSC::Machete::Status.failed) if update
    end

    def self.included(obj)
      # track the classes that include this module
      self.classes << Kernel.const_get(obj.name) unless obj.name.nil?

      # add class methods
      obj.send(:extend, ClassMethods)

      # Store job object info in a JSON column and replace old column methods
      if obj.respond_to?(:column_names) && obj.column_names.include?('job_cache')
        obj.store :job_cache, accessors: [ :script, :pbsid, :host ], coder: JSON
        delegate :script_name, to: :job
        define_method :job_path do
          job.path
        end
      else
        define_method(:job_cache) do
          {
            script: (job_path && script_name) ? Pathname.new(job_path).join(script_name) : nil,
            pbsid: pbsid,
            host: nil
          }
        end
      end
    end

    def self.classes
      @classes ||= []
    end

    # for each Statusable, call update_status! on active jobs
    def self.update_status_of_all_active_jobs
      Rails.logger.warn "Statusable.classes Array is empty. This should contain a list of all the classes that include Statusable." if self.classes.empty?

      self.classes.each do |klass|
        klass.active.to_a.each(&:update_status!) if klass.respond_to?(:active)
      end
    end

    # class methods to extend a model with
    module ClassMethods
      # scope to get all of the jobs that are in an active state
      # or have a pbsid
      def active
        # FIXME: what about OR i.e. where
        #
        #     status in active_values OR (pbsid != null and status == null)
        #
        # will need to use STRING for the sql instead of this.
        where(status: OSC::Machete::Status.active_values.map(&:char))
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

      begin
        self.status = new_job.status
      rescue PBS::Error => e
        # a safe default
        self.status = OSC::Machete::Status.queued

        # log the error
        Rails.logger.error("After submitting the job with pbsid: #{pbsid}," \
                           " checking the status raised a PBS::Error: #{e.message}")
      end
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

      if self.respond_to? :script_name && !script_name.nil?
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
      # this will make it easier to differentiate from current_status
      cached_status = status

      # by default only update if its an active job
      if  (cached_status.not_submitted? && pbsid) || cached_status.active? || force
        # get the current status from the system
        current_status = job.status

        # if job is done, lets re-validate
        if current_status.completed?
          current_status = results_valid? ? OSC::Machete::Status.passed : OSC::Machete::Status.failed
        end

        if (current_status != cached_status) || force
          self.status = current_status
          self.save
        end
      end

    rescue PBS::Error => e
      # we log the error but we just don't update the status
      Rails.logger.error("During update_status! call on job with pbsid #{pbsid} and id #{id}" \
                          " a PBS::Error was thrown: #{e.message}")
    end
  end
end
