module Accounting
  class Invoice < FinancialTransaction
    class Context < Dry::Validation::Contract
      params do
        required(:snapshot_number).filled(:integer)
        required(:project_name).filled(:string)
        required(:project_version_retention_guarantee_rate).filled(:decimal, gteq?: 0, lteq?: 1)
        required(:project_version_number).filled(:integer, gteq?: 0)
        required(:project_version_date).filled(:string)
        required(:project_total_amount).filled(:decimal, gteq?: 0)
        required(:project_total_amount_before_discounts).filled(:decimal, gteq?: 0)
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
        optional(:project_version_discounts).array(:hash) do
          required(:original_discount_uuid).filled(:string)
          required(:kind).filled(:string)
          required(:value).filled(:decimal)
          required(:amount).filled(:decimal, gteq?: 0)
          required(:position).filled(:integer, gteq?: 0)
          optional(:name).maybe(:string)
        end
      end

      rule(:project_version_date) do
        key.failure("must be a valid datetime") unless Time.parse(value) rescue false
      end
    end

    include FacturXAttachable

    NUMBER_PREFIX = "INV".freeze

    has_one :credit_note, class_name: "Accounting::CreditNote", foreign_key: :holder_id
    has_one :invoice_payment_status, class_name: "Accounting::InvoicePaymentStatus"
    has_many :payments, class_name: "Accounting::Payment", foreign_key: :invoice_id

    enum :status,
         {
           posted: "posted",
           cancelled: "cancelled"
         },
         default: :posted,
         validate: true

    def payment_status
      invoice_payment_status.status
    end
  end
end
