module Accounting
  class Invoice < FinancialTransaction
    class Context < Dry::Validation::Contract
      params do
        required(:project_name).filled(:string)
        required(:project_version_retention_guarantee_rate).filled(:decimal, gteq?: 0, lteq?: 1)
        required(:project_version_number).filled(:integer, gteq?: 0)
        required(:project_version_date).filled(:string)
        required(:project_total_amount).filled(:decimal, gteq?: 0)
        required(:project_total_previously_billed_amount).filled(:decimal, gteq?: 0)
        required(:project_version_items).array(:hash) do
          required(:original_item_uuid).filled(:string)
          required(:group_id).maybe(:integer, gteq?: 0)
          required(:name).filled(:string)
          optional(:description).maybe(:string)
          required(:quantity).filled(:integer, gteq?: 0)
          required(:unit).filled(:string)
          required(:unit_price_amount).filled(:decimal, gteq?: 0)
          required(:tax_rate).filled(:decimal, gteq?: 0)
          required(:previously_billed_amount).filled(:decimal, gteq?: 0)
        end
        required(:project_version_item_groups).array(:hash) do
          required(:id).filled(:integer, gt?: 0)
          required(:name).filled(:string)
          optional(:description).maybe(:string)
        end
      end

      rule(:project_version_date) do
        key.failure("must be a valid datetime") unless Time.parse(value) rescue false
      end
    end

    UNPUBLISHED_STATUS = [ "draft", "voided" ].freeze
    NUMBER_UNPUBLISHED_PREFIX = "PRO".freeze
    PUBLISHED_STATUS = [ "posted", "cancelled" ].freeze
    NUMBER_PUBLISHED_PREFIX = "INV".freeze

    has_one :credit_note, class_name: "Accounting::CreditNote", foreign_key: :holder_id

    enum :status,
         {
           draft: "draft",
           voided: "voided",
           posted: "posted",
           cancelled: "cancelled"
         },
         default: :draft,
         validate: true

    validate :valid_number

    scope :published, -> { where(status: PUBLISHED_STATUS) }

    scope :unpublished, -> { where(status: UNPUBLISHED_STATUS) }

    private

    def valid_number
      prefix = UNPUBLISHED_STATUS.include?(status) ? NUMBER_UNPUBLISHED_PREFIX : NUMBER_PUBLISHED_PREFIX
      regex = /^#{prefix}-\d{4}-\d+$/
      unless number.match?(regex)
        errors.add(:number, "must match format #{prefix}-YEAR-SEQUENCE")
      end
    end
  end
end
