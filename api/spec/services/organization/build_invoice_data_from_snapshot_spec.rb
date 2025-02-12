# frozen_string_literal: true

require 'rails_helper'
require "support/shared_contexts/organization/a_company_with_a_project_with_three_item_groups"

RSpec.describe Organization::BuildInvoiceDataFromSnapshot do
  describe '.call' do
    subject(:result) { described_class.call(snapshot) }

    include_context 'a company with a project with three item groups'
    let(:snapshot) { FactoryBot.create(:completion_snapshot, project_version: project_version, completion_snapshot_items_attributes: project_version.items.map.with_index { |item, index| { item_id: item.id, completion_percentage: BigDecimal(index) } }) }

    # Ensure all required associations are present
    it 'returns a valid Result struct' do
      expect(result).to be_a(described_class::Result)
    end

    context 'when checking payment terms' do
      before do
        company_config.update!(settings: {
          payment_term: {
            days: 30,
            methods: [ 'bank_transfer', 'check' ]
          }
        })
      end

      it 'correctly maps payment term data' do
        expect(result.payment_term).to have_attributes(
          days: 30,
          accepted_methods: [ 'bank_transfer', 'check' ]
        )
      end
    end

    context 'when checking seller information' do
      let(:company) do
        FactoryBot.create(:company,
          name: 'Test Company',
          phone: '123456789',
          registration_number: '123456789',
          rcs_city: 'Paris',
          rcs_number: 'RCS123',
          vat_number: 'VAT123',
          address_city: 'Paris',
          address_street: '123 Street',
          address_zipcode: '75001'
        )
      end

      # rubocop:disable RSpec/ExampleLength
      it 'correctly maps seller data', :aggregate_failures do
        expect(result.seller).to have_attributes(
          name: 'Test Company',
          phone: '123456789',
          siret: '123456789',
          rcs_city: 'Paris',
          rcs_number: 'RCS123',
          vat_number: 'VAT123'
        )
        expect(result.seller.address).to have_attributes(
          city: 'Paris',
          street: '123 Street',
          zip: '75001'
        )
      end
    end

    context 'when checking items' do
      let(:project_version_first_item_group_item) do
        FactoryBot.create(:item,
          project_version: project_version,
          item_group: project_version_first_item_group,
          name: 'Test Item',
          description: 'Test Description',
          quantity: 2,
          unit: 'hours',
          unit_price_cents: 5000
        )
      end

      before do
        FactoryBot.create(:completion_snapshot_item,
          completion_snapshot: snapshot,
          item: project_version_first_item_group_item,
          completion_percentage: 0.75
        )
      end

      it 'correctly maps items data' do
        expect(result.items.first).to have_attributes(
          name: 'Test Item',
          description: 'Test Description',
          item_group_id: project_version_first_item_group.id,
          quantity: 2,
          unit: 'hours',
          unit_price: BigDecimal('50.00'),
          previous_completion_percentage: BigDecimal('0'),
          new_completion_percentage: BigDecimal('0.75')
        )
      end

      context 'with previous snapshot' do
        before do
          travel_to(1.day.before) {
            FactoryBot.create(
            :completion_snapshot,
            project_version: project_version,
            completion_snapshot_items_attributes: [
              {
                item: project_version_first_item_group_item,
                completion_percentage: 0.5
              }
            ]
          )
          }
        end

        it 'correctly handles previous completion percentage' do
          expect(result.items.first).to have_attributes(
            previous_completion_percentage: BigDecimal('0.5'),
            new_completion_percentage: BigDecimal('0.75')
          )
        end
      end
    end

    context 'when checking project context' do
      before do
        travel_to(1.day.before) {
          previous_completion_snapshot =  FactoryBot.create(
          :completion_snapshot,
          project_version: project_version,
          completion_snapshot_items_attributes: []
          )

          FactoryBot.create(:invoice, completion_snapshot: previous_completion_snapshot, number: "01", issue_date: Time.now, delivery_date: Time.now, total_amount_excl_tax: 1000, total_amount_incl_tax: 1200, tax_amount: 200)
        }
      end

      let(:project_version_first_item_group_item) do
        FactoryBot.create(:item,
          project_version: project_version,
          item_group: project_version_first_item_group,
          name: 'Test Item 1',
          description: 'Test Description',
          quantity: 2,
          unit: 'hours',
          unit_price_cents: 5000
        )
      end
      let(:project_version_second_item_group_item) do
        FactoryBot.create(:item,
          project_version: project_version,
          item_group: project_version_first_item_group,
          name: 'Test Item 2',
          description: 'Test Description',
          quantity: 3,
          unit: 'hours',
          unit_price_cents: 1000
        )
      end
      let(:project_version_third_item_group_item) do
        FactoryBot.create(:item,
          project_version: project_version,
          item_group: project_version_first_item_group,
          name: 'Test Item 3',
          description: 'Test Description',
          quantity: 10,
          unit: 'hours',
          unit_price_cents: 100
        )
      end

      it 'correctly calculates project context data' do
        expect(result.project_context).to have_attributes(
          name: project.name,
          version: project_version.number,
          total_amount_cents: (2 * 5000 + 3 * 1000 + 10 * 100),
          previously_billed_amount: 1000
        )
      end
    end

    context 'with missing dependencies' do
      context 'when project version is missing' do
        let(:snapshot) { FactoryBot.build(:completion_snapshot, project_version: nil) }

        it 'raises an error' do
          expect { result }.to raise_error(
            Error::UnprocessableEntityError,
            'Project version is not defined'
          )
        end
      end
    end
  end
end
