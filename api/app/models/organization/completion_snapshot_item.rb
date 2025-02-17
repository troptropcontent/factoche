class Organization::CompletionSnapshotItem < ApplicationRecord
  belongs_to :item
  belongs_to :completion_snapshot

  validates :completion_percentage,
    numericality: {
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 1
  }
end
