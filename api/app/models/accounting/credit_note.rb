module Accounting
  class CreditNote < FinancialTransaction
    class Context < Dry::Validation::Contract
      params do
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
    NUMBER_PREFIX = "CN".freeze
    enum :status,
          {
            draft: "draft",
            posted: "posted"
          },
          default: :draft,
          validate: true
          validate :valid_number

    validate :valid_number
    private

    def valid_number
      regex = /^#{NUMBER_PREFIX}-\d{4}-\d+$/
      unless number.match?(regex)
        errors.add(:number, "must match format #{pattern}-YEAR-SEQUENCE")
      end
    end
  end
end
