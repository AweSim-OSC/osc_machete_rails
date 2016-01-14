module OscMacheteRails::JobHelpers
  private
    def parse_job!(args)
      jobs = args.grep(/:jobs$/)
      args = args - jobs

      job_attrib = jobs.first || "#{args.first.underscore}_job:jobs"
      Rails::Generators::GeneratedAttribute.parse job_attrib
    end
end
