class Organization::CompletionSnapshot < ApplicationRecord
  belongs_to :project_version, class_name: "Organization::ProjectVersion"
end
