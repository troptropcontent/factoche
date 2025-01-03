class Organization::Item < ApplicationRecord
  VALID_HOLDER_TYPES = [ "Organization::ItemGroup", "Organization::ProjectVersion" ].freeze

  belongs_to :holder, polymorphic: true


  validates :name, presence: true, uniqueness: { scope: [ :holder_type, :holder_id ] }
  validates :quantity, presence: true
  validates :unit, presence: true
  validates :unit_price_cents, presence: true
  validates :holder_type, inclusion: { in: VALID_HOLDER_TYPES }

  def amount_cents
    unit_price_cents * quantity
  end
end
