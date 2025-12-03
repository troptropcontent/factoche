require 'rails_helper'
require 'support/shared_contexts/organization/a_company_with_a_client_and_a_member'
module Organization
  module DraftOrders
    RSpec.describe ConvertToOrder do
      describe '#call', :aggregate_failures do
        subject(:result) { described_class.call(draft_order_id) }

        include_context 'a company with a client and a member'

        let(:quote) { FactoryBot.create(:quote, :with_version, company: company, client: client, bank_detail: company.bank_details.last) }
        let(:draft_order) { FactoryBot.create(:draft_order, :with_version, company: company, client: client, original_project_version: quote.last_version, bank_detail: company.bank_details.last) }
        let(:draft_order_id) { draft_order.id }

        context 'when the draft order is valid' do
          before do
            allow(Projects::Duplicate).to receive(:call).and_return(
              OpenStruct.new(
                success?: true,
                data: {
                  new_project: FactoryBot.build_stubbed(:order),
                  new_project_version: FactoryBot.build_stubbed(:project_version, id: 22)
                }
              )
            )
            allow(ProjectVersions::GeneratePdfJob).to receive(:perform_async)
          end

          it 'duplicates the draft order into a new order' do
            result
            expect(Projects::Duplicate).to have_received(:call).with(draft_order, Order)
          end

          it 'marks the draft order as posted' do
            travel_to Time.current do
              result
              expect(draft_order.reload.posted).to be true
              expect(draft_order.reload.posted_at).to eq(Time.current)
            end
          end

          it 'triggers PDF generation for the order version' do
            result
            expect(ProjectVersions::GeneratePdfJob).to have_received(:perform_async).with({ "project_version_id" => 22 })
          end

          it 'returns the new order' do
            new_order = FactoryBot.build_stubbed(:order)
            allow(Projects::Duplicate).to receive(:call).and_return(
              OpenStruct.new(
                success?: true,
                data: {
                  new_project: new_order,
                  new_project_version: FactoryBot.build_stubbed(:project_version)
                }
              )
            )

            expect(result.data).to eq(new_order)
          end
        end

        context 'when the draft order has already been converted' do
          context 'when posted is true' do
            let(:draft_order) { FactoryBot.create(:draft_order, :with_version, company: company, client: client, original_project_version: quote.last_version, bank_detail: company.bank_details.last, posted: true, posted_at: Time.current) }

            it 'raises an UnprocessableEntityError' do
              expect(result.error.message).to include("Draft order has already been converted to an order")
            end
          end

          context 'when the draft order has associated orders' do
            before do
              stubed_draft_order = FactoryBot.build_stubbed(:draft_order)
              allow(DraftOrder).to receive(:find).with(draft_order_id).and_return(stubed_draft_order)
              allow(stubed_draft_order).to receive(:orders).and_return([ FactoryBot.build_stubbed(:order) ])
            end

            it 'raises an UnprocessableEntityError' do
              expect(result.error.message).to include("Draft order has already been converted to an order")
            end
          end
        end

        context 'when the duplication fails' do
          before do
            allow(Projects::Duplicate).to receive(:call).and_return(
              OpenStruct.new(
                success?: false,
                failure?: true,
                error: 'Duplication error'
              )
            )
          end

          it 'raises the error from the duplication service' do
            expect(result.error.message).to eq('Duplication error')
          end
        end

        context 'when draft order has discounts' do
          let(:draft_order_with_discounts) { FactoryBot.create(:draft_order, :with_version, company: company, client: client, original_project_version: quote.last_version, bank_detail: company.bank_details.last) }
          let(:draft_order_version) { draft_order_with_discounts.last_version }
          let(:draft_order_id) { draft_order_with_discounts.id }

          let!(:percentage_discount) do
            FactoryBot.create(:discount,
              project_version: draft_order_version,
              original_discount_uuid: SecureRandom.uuid,
              kind: "percentage",
              value: 0.1,
              amount: 100,
              position: 1,
              name: "Volume discount"
            )
          end

          let!(:fixed_amount_discount) do
            FactoryBot.create(:discount,
              project_version: draft_order_version,
              original_discount_uuid: SecureRandom.uuid,
              kind: "fixed_amount",
              value: 75,
              amount: 75,
              position: 2,
              name: "Loyalty discount"
            )
          end

          it 'carries forward all discounts to the order' do
            result = described_class.call(draft_order_id)

            expect(result).to be_success
            order = result.data
            order_version = order.versions.first

            # Check discounts count
            expect(order_version.discounts.count).to eq(draft_order_version.discounts.count)

            # Check each discount is preserved
            draft_order_version.discounts.ordered.each do |draft_order_discount|
              order_discount = order_version.discounts.find_by(
                original_discount_uuid: draft_order_discount.original_discount_uuid
              )

              expect(order_discount).to be_present
              expect(order_discount.kind).to eq(draft_order_discount.kind)
              expect(order_discount.value).to eq(draft_order_discount.value)
              expect(order_discount.amount).to eq(draft_order_discount.amount)
              expect(order_discount.position).to eq(draft_order_discount.position)
              expect(order_discount.name).to eq(draft_order_discount.name)
              expect(order_discount.original_discount_uuid).to eq(draft_order_discount.original_discount_uuid)
            end
          end

          it 'preserves discount original_discount_uuid for tracking' do
            result = described_class.call(draft_order_id)
            order_version = result.data.versions.first

            original_uuids = draft_order_version.discounts.pluck(:original_discount_uuid)
            order_uuids = order_version.discounts.pluck(:original_discount_uuid)

            expect(order_uuids).to match_array(original_uuids)
          end
        end
      end
    end
  end
end
