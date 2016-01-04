<% module_namespacing do -%>
class <%= class_name %> < <%= parent_class_name.classify %>
  include OscMacheteRails::Statusable

<% attributes.select(&:reference?).each do |attribute| -%>
  belongs_to :<%= attribute.name %><%= ', polymorphic: true' if attribute.polymorphic? %>
<% end -%>
<% if attributes.any?(&:password_digest?) -%>
  has_secure_password
<% end -%>

  before_destroy { |j| j.job.delete(rmdir: true) if j.job }

  # Determine if the results are valid
  # def results_valid?
  #   # CODE GOES HERE
  # end
end
<% end -%>
