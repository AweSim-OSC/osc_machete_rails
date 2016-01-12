module OscMacheteRails
  # Methods that deal with pbs batch job status management
  # within a Rails ActiveRecord model
  module Statusable


    delegate :submitted?, :completed?, :failed?, :active?, to: :status

    def status=(s)
      super(s.nil? ? s : s.to_s)
    end

    # getter returns a Status value from CHAR or a Status value
    def status
      OSC::Machete::Status.new(super)
    end

    # track the classes that include this module
    def self.included(base)
      @classes ||= []
      @classes << Kernel.const_get(base.name) unless base.name.nil?

      base.send(:extend, ClassMethods)
    end

    def self.classes
      @classes
    end

    def self.update_status_of_all_active_jobs
      self.classes.each do |cls|
        #FIXME: problems with approach
        #  - doesn't capture jobs that have pbsid and no cached status unless
        #    active includes that
        #  - requires at least 1 (if not 2) db queries for each Job model
        #    and if we are thinking about doing this on each request...
        #    would be more efficient to know the resource being requested
        #    and update models just for that...

        # given the class name as a string
        # how do we turn it into a constant and call method on it
        # like cls = "Simulation" and cls.count
        cls.active.to_a.each(&:update_status!) if cls.respond_to?(:active)
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
        where(status: OSC::Machete::Status.active_values.map(&:to_s))
      end
    end

    # Setter that accepts an OSC::Machete::Job instance
    #
    # @param [Job] new_job The Job object to be assigned to the Statusable instance.
    def job=(new_job)
      self.pbsid = new_job.pbsid
      self.job_path = new_job.path.to_s
      self.script_name = new_job.script_name if respond_to?(:script_name=)
      self.status = new_job.status
    end

    # Returns associated OSC::Machete::Job instance
    def job
      script_path = respond_to?(:script_name) && script_name ? Pathname.new(job_path).join(script_name) : nil
      OSC::Machete::Job.new(pbsid: pbsid, script: script_path)
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
