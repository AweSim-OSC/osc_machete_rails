<% module_namespacing do -%>
class <%= class_name %> < <%= parent_class_name.classify %>
  has_many :<%= job.plural_name %>, dependent: :destroy
  has_machete_workflow_of :<%= job.plural_name %>

<% attributes.select(&:reference?).each do |attribute| -%>
  belongs_to :<%= attribute.name %><%= ', polymorphic: true' if attribute.polymorphic? %>
<% end -%>
<% if attributes.any?(&:password_digest?) -%>
  has_secure_password
<% end -%>

  # Name that defines the template/target dirs
  def staging_template_name
    "<%= file_name %>"
  end

  # Define tasks to do after staging template directory typically copy over
  # uploaded files here
  # def after_stage(staged_dir)
  #   # CODE HERE
  # end

  # Build an array of Machete jobs that are then submitted to the batch server
  def build_jobs(staged_dir, job_list = [])
    job_list << OSC::Machete::Job.new(script: staged_dir.join("main.sh"))
  end

  # Make copy of workflow
  def copy
    self.dup
  end
end
<% end -%>
