<% module_namespacing do -%>
module <%= class_name %>Helper
  def job_status_label(job)
    label_class = 'label-default'
    if job.failed?
      label_class = 'label-danger'
    elsif job.completed?
      label_class = 'label-success'
    elsif job.active?
      label_class = 'label-primary'
    end

    content_tag :span, class: %I(label #{label_class}) do
      job.status_human_readable
    end
  end
end
<% end -%>
