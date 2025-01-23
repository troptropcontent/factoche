class Organization::CompletionSnapshotItem < ApplicationRecord
  belongs_to :item
  belongs_to :completion_snapshot
end
