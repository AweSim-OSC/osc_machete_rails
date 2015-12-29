module OscMacheteRails
  module Helper
    def status_label(job)
      label_class = 'label-default'
      if job.failed?
        label_class = 'label-danger'
      elsif job.completed?
        label_class = 'label-success'
      elsif job.active?
        label_class = 'label-primary'
      end if job

      status = job ? job.status : OSC::Machete::Status.not_submitted
      content_tag :span, class: %I(label #{label_class}) do
        status.inspect
      end
    end
  end
end

ActionView::Base.send :include, OscMacheteRails::Helper
