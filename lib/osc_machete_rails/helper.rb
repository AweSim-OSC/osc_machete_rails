module OscMacheteRails
  module Helper
    def status_label(job, tag = :span)
      job ||= OpenStruct.new status: OSC::Machete::Status.not_submitted
      text = job.status.to_s

      label_class = 'label-default'
      if job.failed?
        label_class = 'label-danger'
      elsif job.passed?
        label_class = 'label-success'
        text = "Completed"
      elsif job.active?
        label_class = 'label-primary'
      end

      content_tag tag, class: %I(status-label label #{label_class}) do
        text
      end
    end
    alias_method :job_status_label, :status_label
  end
end

ActionView::Base.send :include, OscMacheteRails::Helper
