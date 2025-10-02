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
          required(:project).value(:hash) do
            required(:name).filled(:string)
          end
          required(:project_version).value(:hash) do
            required(:id).filled(:integer)
            required(:number).filled(:integer)
            required(:created_at).filled(:time)
            required(:retention_guarantee_rate).filled(:decimal)
            required(:items).array(:hash) do
              required(:original_item_uuid).filled(:string)
              required(:group_id).maybe(:integer)
              required(:name).filled(:string)
              required(:description).maybe(:string)
              required(:quantity).filled(:integer)
              required(:unit).filled(:string)
              required(:unit_price_amount).filled(:decimal)
              required(:tax_rate).filled(:decimal)
            end
            required(:item_groups).array(:hash) do
              required(:id).filled(:integer)
              required(:name).filled(:string)
              required(:description).maybe(:string)
            end
          end
          required(:new_invoice_items).array(:hash) do
            required(:original_item_uuid).filled(:string)
            required(:invoice_amount).filled(:decimal)
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

        @context = {
          snapshot_number: @validated_params[:snapshot_number],
          project_name: project.fetch(:name),
          project_version_number: project_version.fetch(:number),
          project_version_date: project_version.fetch(:created_at).iso8601,
          project_version_retention_guarantee_rate: project_version.fetch(:retention_guarantee_rate),
          project_total_amount: find_project_version_total(project_version_items),
          project_total_previously_billed_amount: project_version_items.sum { |project_version_item| project_version_item.fetch(:previously_billed_amount) },
          project_version_items: project_version_items,
          project_version_item_groups: build_project_version_item_groups_data(project_version.fetch(:item_groups))
        }
      end

      def build_draft_invoice_context(project, project_version, issue_date)
        project_version_items = build_project_version_items_data(project_version.fetch(:items), issue_date)

        {
          project_name: project.fetch(:name),
          project_version_number: project_version.fetch(:number),
          project_version_date: project_version.fetch(:created_at).iso8601,
          project_version_retention_guarantee_rate: project_version.fetch(:retention_guarantee_rate),
          project_total_amount: find_project_version_total(project_version_items),
          project_total_previously_billed_amount: project_version_items.sum { |project_version_item| project_version_item.fetch(:previously_billed_amount) },
          project_version_items: project_version_items,
          project_version_item_groups: build_project_version_item_groups_data(project_version.fetch(:item_groups))
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

      def fetch_previous_invoices_data!(original_item_uuids, issue_date)
        result = FinancialTransactions::FindInvoicedAmountForHolderIds.call(original_item_uuids, issue_date)
        raise result.error if result.failure?

        result.data
      end

      def find_project_version_total(project_version_items)
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

      def find_previously_invoiced_amount_for_item(original_item_uuids, issue_date)
        Accounting::FinancialTransactionLine.joins(:financial_transaction)
          .where(
            holder_id: original_item_uuids,
            financial_transaction: { issue_date: ...issue_date, status: :posted }
          )
          .select("original_item_uuid")
          .sum("excl_tax_amount")
          .group("9aa7263b-be27-4642-8c1f-aca123ed4aaa")
      end

      def totals
        return @totals if @totals

        project_version = @validated_params[:project_version]
        new_invoice_items = @validated_params[:new_invoice_items]
        retention_guarantee_rate = project_version[:retention_guarantee_rate].to_d

        @totals = new_invoice_items.each_with_object({
          total_excl_tax_amount: 0,
          total_including_tax_amount: 0,
          total_excl_retention_guarantee_amount: 0
        }) do |new_invoice_item, totals|
          project_version_item = project_version.fetch(:items).find { |item|
            item.fetch(:original_item_uuid) == new_invoice_item.with_indifferent_access.fetch(:original_item_uuid)
          }
          project_version_item_tax_rate = project_version_item.fetch(:tax_rate).to_d

          new_invoice_item_excl_tax_amount = new_invoice_item.with_indifferent_access.fetch(:invoice_amount).to_d
          new_invoice_item_including_tax_amount = new_invoice_item_excl_tax_amount * (1 + project_version_item_tax_rate)
          new_invoice_item_excl_retention_guarantee_amount = new_invoice_item_including_tax_amount * (1 - retention_guarantee_rate)

          totals[:total_excl_tax_amount] += new_invoice_item_excl_tax_amount
          totals[:total_including_tax_amount] += new_invoice_item_including_tax_amount
          totals[:total_excl_retention_guarantee_amount] += new_invoice_item_excl_retention_guarantee_amount
        end.transform_values { |total| total.round(2) }
      end
    end
  end
end
