require 'rails_helper'
require "support/shared_contexts/organization/a_company_with_a_project_with_three_item_groups"
module Organization
  module Projects
    RSpec.describe GetInvoicedAmountForProjectItems do
      include_context 'a company with a project with three item groups'
      # rubocop:disable RSpec/MultipleMemoizedHelpers
      describe '.call' do
        subject(:result) { described_class.call(company.id, project.id, issue_date) }

        let(:issue_date) { Time.current }


        context "when no error is raised" do
          it { is_expected.to be_success }

          context 'when there are no financial transactions' do
            # rubocop:disable RSpec/ExampleLength
            it 'returns zero amounts for all items' do
              expect(result.data).to contain_exactly(
                {
                  original_item_uuid: project_version_first_item_group_item.original_item_uuid,
                  invoiced_amount: 0
                },
                {
                  original_item_uuid: project_version_second_item_group_item.original_item_uuid,
                  invoiced_amount: 0
                },
                {
                  original_item_uuid: project_version_third_item_group_item.original_item_uuid,
                  invoiced_amount: 0
                }
              )
            end
            # rubocop:enable RSpec/ExampleLength
          end

          context 'when there are financial transactions' do
            before do
              previous_invoice = FactoryBot.create(
                :completion_snapshot_invoice,
                company_id: company.id,
                holder_id: project_version.id
              )

              FactoryBot.create(
                :financial_transaction_line,
                holder_id: project_version_first_item_group_item.original_item_uuid,
                financial_transaction: previous_invoice,
                quantity: 2,
                unit_price_amount: 2,
                excl_tax_amount: 4
              )

              FactoryBot.create(
                :financial_transaction_line,
                holder_id: project_version_second_item_group_item.original_item_uuid,
                financial_transaction: previous_invoice,
                quantity: 10,
                unit_price_amount: 3,
                excl_tax_amount: 30
              )
            end

            # rubocop:disable RSpec/ExampleLength
            it 'returns correct amounts considering both invoices and credit notes' do
              expect(result.data).to contain_exactly(
                {
                  original_item_uuid: project_version_first_item_group_item.original_item_uuid,
                  invoiced_amount: 4
                },
                {
                  original_item_uuid: project_version_second_item_group_item.original_item_uuid,
                  invoiced_amount: 30
                },
                {
                  original_item_uuid: project_version_third_item_group_item.original_item_uuid,
                  invoiced_amount: 0
                }
              )
            end
            # rubocop:enable RSpec/ExampleLength
          end

          context 'when transactions are after the issue_date' do
            let(:future_date) { issue_date + 1.day }

            before do
              previous_invoice = FactoryBot.create(
                :completion_snapshot_invoice,
                company_id: company.id,
                holder_id: project_version.id,
                issue_date: future_date
              )

              FactoryBot.create(
                :financial_transaction_line,
                holder_id: project_version_first_item_group_item.original_item_uuid,
                financial_transaction: previous_invoice,
                quantity: 2,
                unit_price_amount: 2,
                excl_tax_amount: 4
              )

              FactoryBot.create(
                :financial_transaction_line,
                holder_id: project_version_second_item_group_item.original_item_uuid,
                financial_transaction: previous_invoice,
                quantity: 10,
                unit_price_amount: 3,
                excl_tax_amount: 30
              )
            end

            # rubocop:disable RSpec/ExampleLength
            it 'does not include future transactions' do
              expect(result.data).to contain_exactly(
                {
                  original_item_uuid: project_version_first_item_group_item.original_item_uuid,
                  invoiced_amount: 0
                },
                {
                  original_item_uuid: project_version_second_item_group_item.original_item_uuid,
                  invoiced_amount: 0
                },
                {
                  original_item_uuid: project_version_third_item_group_item.original_item_uuid,
                  invoiced_amount: 0
                }
              )
            end
            # rubocop:enable RSpec/ExampleLength
          end

          context 'when project has no items' do
            before do
              project_version.items.destroy_all
            end

            it 'returns an empty array' do
              expect(result.data).to eq([])
            end
          end
        end

        context "when an error is raised" do
          before {
            allow(Accounting::FinancialTransactionLine).to receive(:joins).and_raise("Database error")
          }

          it { is_expected.to be_failure }

          it "returns the error that get raised" do
            expect(result.error).to eq("Failed to get invoiced amounts for project items: Database error")
          end
        end
      end
      # rubocop:enable RSpec/MultipleMemoizedHelpers
    end
  end
end
