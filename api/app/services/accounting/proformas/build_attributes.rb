module Accounting
  module Proformas
    class BuildAttributes
      include ApplicationService

      class Contract < Dry::Validation::Contract
        params do
          required(:company_id).filled(:integer)
          required(:client_id).filled(:integer)
          required(:snapshot_number).filled(:integer)
          required(:issue_date).filled(:time)
          required(:project).hash(ProjectSchema)
          required(:project_version).hash(ProjectVersionSchema)
          required(:new_invoice_items).array(:hash) do
            required(:original_item_uuid).filled(:string)
            required(:invoice_amount).filled(:decimal)
          end
          optional(:new_invoice_discounts).array(:hash) do
            required(:original_discount_uuid).filled(:string)
            required(:discount_amount).filled(:decimal, gteq?: 0)
          end
        end
      end

      def call(args)
          @validated_params = validate!(args, Contract)

          {
            company_id: @validated_params[:company_id],
            client_id: @validated_params[:client_id],
            holder_id: @validated_params.dig(:project_version, :id),
            status: :draft,
            issue_date: @validated_params[:issue_date],
            context: context,
            total_excl_tax_amount: totals.fetch(:total_excl_tax_amount),
            total_including_tax_amount: totals.fetch(:total_including_tax_amount),
            total_excl_retention_guarantee_amount: totals.fetch(:total_excl_retention_guarantee_amount)
          }
      end

      private

      def context
        return @context if @context

        project = @validated_params[:project]
        project_version = @validated_params[:project_version]
        project_version_items = build_project_version_items_data(project_version[:items], @validated_params[:issue_date])
        project_version_items_amount = project_version_items.sum { |item| item.fetch(:quantity) * item.fetch(:unit_price_amount) }
        previously_billed_amount_for_items = project_version_items.sum { |project_version_item| project_version_item.fetch(:previously_billed_amount) }
        project_version_discounts = build_project_version_discounts_data(project_version[:discounts] || [], @validated_params[:issue_date])
        project_version_discounts_amount = project_version_discounts.sum { |item| item.fetch(:amount) }
        previously_billed_amount_for_discounts = project_version_discounts.sum { |project_version_discount| project_version_discount.fetch(:previously_billed_amount) }

        @context = {
          snapshot_number: @validated_params[:snapshot_number],
          project_name: project.fetch(:name),
          project_version_number: project_version.fetch(:number),
          project_version_date: project_version.fetch(:created_at).iso8601,
          project_version_retention_guarantee_rate: project_version.fetch(:retention_guarantee_rate),
          project_total_amount: project_version_items_amount - project_version_discounts_amount,
          project_total_amount_before_discounts: project_version_items_amount,
          project_total_previously_billed_amount: previously_billed_amount_for_items + previously_billed_amount_for_discounts,
          project_version_items: project_version_items,
          project_version_item_groups: build_project_version_item_groups_data(project_version.fetch(:item_groups)),
          project_version_discounts: project_version_discounts
        }
      end

      def build_project_version_items_data(project_version_items, issue_date)
        previous_invoices_data = fetch_previous_invoices_data!(project_version_items.pluck(:original_item_uuid), issue_date)
        project_version_items.map do |item|
          {
            original_item_uuid: item.fetch(:original_item_uuid),
            group_id: item.fetch(:group_id),
            name: item.fetch(:name),
            description: item.fetch(:description),
            quantity: item.fetch(:quantity),
            unit: item.fetch(:unit),
            unit_price_amount: item.fetch(:unit_price_amount),
            tax_rate: item.fetch(:tax_rate),
            previously_billed_amount: previous_invoices_data.dig(item.fetch(:original_item_uuid), :invoices_amount).to_d - previous_invoices_data.dig(item.fetch(:original_item_uuid), :credit_notes_amount).to_d
          }
        end
      end

      def build_project_version_discounts_data(project_version_discounts, issue_date)
          previous_invoices_data = fetch_previous_invoices_data!(project_version_discounts.pluck(:original_discount_uuid), issue_date)
          project_version_discounts.map do |discount|
            {
              original_discount_uuid: discount.fetch(:original_discount_uuid),
              kind: discount.fetch(:kind),
              value: discount.fetch(:value),
              amount: discount.fetch(:amount),
              position: discount.fetch(:position),
              name: discount.fetch(:name),
              previously_billed_amount: previous_invoices_data.dig(discount.fetch(:original_discount_uuid), :invoices_amount).to_d - previous_invoices_data.dig(discount.fetch(:original_discount_uuid), :credit_notes_amount).to_d
            }
          end
      end

      def fetch_previous_invoices_data!(uuids, issue_date)
        result = FinancialTransactions::FindInvoicedAmountForHolderIds.call(uuids, issue_date)
        raise result.error if result.failure?

        result.data
      end

      def find_project_version_total(project_version_items, project_version_discounts)
        project_version_items.sum do |project_version_item|
          project_version_item.fetch(:quantity) * project_version_item.fetch(:unit_price_amount)
        end
      end

      def build_project_version_item_groups_data(project_version_item_groups)
        project_version_item_groups.map do |group|
          {
            id: group.fetch(:id),
            name: group.fetch(:name),
            description: group.fetch(:description)
          }
        end
      end

      def build_manual_discounts_map
        return {} unless @validated_params[:new_invoice_discounts].present?

        @validated_params[:new_invoice_discounts].each_with_object({}) do |discount, hash|
          uuid = discount[:original_discount_uuid]
          amount = discount[:discount_amount]
          hash[uuid] = amount
        end
      end

      def totals
        return @totals if @totals

        project_version = @validated_params[:project_version]

        # Items data
        project_version_items = project_version[:items]
        invoice_items = @validated_params[:new_invoice_items]
        invoice_items_amount = invoice_items.sum { |item| item.with_indifferent_access.fetch(:invoice_amount).to_d }

        # Discounts data
        invoice_discounts = @validated_params.fetch(:new_invoice_discounts, [])
        invoice_discounts_amount = invoice_discounts.sum { |discount|discount.fetch(:discount_amount).to_d }
        # Other data
        retention_guarantee_rate = project_version[:retention_guarantee_rate].to_d

        # Calculate totals, distributing the discount proportionally across items
        @totals = invoice_items.each_with_object({
          total_excl_tax_amount: 0,
          total_including_tax_amount: 0,
          total_excl_retention_guarantee_amount: 0,
          total_excl_tax_amount_before_discount: 0
        }) do |invoice_item, totals|
          project_version_item = project_version_items.find { |item|
            item.fetch(:original_item_uuid) == invoice_item.with_indifferent_access.fetch(:original_item_uuid)
          }
          project_version_item_tax_rate = project_version_item.fetch(:tax_rate).to_d

          invoice_amount = invoice_item[:invoice_amount].to_d
          prorated_discount = invoice_items_amount > 0 ? (invoice_amount / invoice_items_amount) * invoice_discounts_amount : 0.to_d

          invoice_amount_including_discount = invoice_amount - prorated_discount
          invoice_amount_including_tax = invoice_amount_including_discount * (1 + project_version_item_tax_rate)
          totals[:total_excl_tax_amount_before_discount] += invoice_amount
          totals[:total_excl_tax_amount] += invoice_amount_including_discount
          totals[:total_including_tax_amount] += invoice_amount_including_tax
          totals[:total_excl_retention_guarantee_amount] += invoice_amount_including_tax * (1 - retention_guarantee_rate)
        end

        @totals = @totals.transform_values { |total| total.round(2) }
      end
    end
  end
end
