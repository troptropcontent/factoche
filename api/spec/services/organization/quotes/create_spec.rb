require 'rails_helper'

module Organization
  module Quotes
    RSpec.describe Create do
      describe '.call' do
        let(:company) { FactoryBot.create(:company, :with_bank_detail) }
        let(:bank_detail_id) { company.bank_details.first.id }
        let(:client) { FactoryBot.create(:client, company: company) }

        let(:valid_params) do
          {
            name: "Construction Project",
            description: "Building renovation",
            retention_guarantee_rate: 0.05,
            address_street: "10 Rue de la Paix",
            address_zipcode: "75002",
            address_city: "Paris",
            groups: [
              {
                uuid: "group-1",
                name: "Preparation",
                description: "Initial setup",
                position: 0
              },
              {
                uuid: "group-2",
                name: "Main Work",
                description: "Core tasks",
                position: 1
              }
            ],
            items: [
              {
                group_uuid: "group-1",
                name: "Site Survey",
                description: "Initial site inspection",
                position: 0,
                quantity: 1,
                unit: "DAY",
                unit_price_amount: 500.00,
                tax_rate: 0.2
              },
              {
                group_uuid: "group-2",
                name: "Wall Construction",
                description: "Building walls",
                position: 0,
                quantity: 1,
                unit: "M2",
                unit_price_amount: 100.00,
                tax_rate: 0.2
              }
            ]
          }
        end

        context 'when params are valid' do
          subject(:result) { described_class.call(company.id, client.id, bank_detail_id, valid_params) }

          it 'creates a quote with all associated records' do
            expect { result }.to change(Quote, :count).by(1)
              .and change(ProjectVersion, :count).by(1)
              .and change(ItemGroup, :count).by(2)
              .and change(Item, :count).by(2)
              .and change(ProjectVersions::GeneratePdfJob.jobs, :size).by(1)
          end

          it 'returns success with the created quote', :aggregate_failures do
            expect(result).to be_success
            expect(result.data).to be_a(Quote)
          end

          # rubocop:disable RSpec/ExampleLength
          it 'sets the correct attributes', :aggregate_failures do
            quote = result.data

            expect(quote.name).to eq("Construction Project")
            expect(quote.description).to eq("Building renovation")
            expect(quote.client_id).to eq(client.id)

            version = quote.versions.first
            expect(version.retention_guarantee_rate).to eq(0.05)
            expect(version.bank_detail_id).to eq(bank_detail_id)

            groups = version.item_groups
            expect(groups.count).to eq(2)
            expect(groups.first.name).to eq("Preparation")
            expect(groups.last.name).to eq("Main Work")

            items = version.items
            expect(items.count).to eq(2)
            expect(items.first.name).to eq("Site Survey")
            expect(items.first.unit_price_amount).to eq(500.00)
          end
          # rubocop:enable RSpec/ExampleLength
        end

        context 'when creating without groups' do
          let(:params_without_groups) do
            valid_params.merge(
              name: "Construction Project",
              description: "Building renovation",
              retention_guarantee_rate: 0.05,
              groups: [],
              items: [
                {
                  name: "Standalone Item",
                  description: "No group",
                  position: 0,
                  unit: "DAY",
                  unit_price_amount: 300.00,
                  quantity: 1,
                  tax_rate: 0.2
                }
              ]
            )
          end

          it 'creates items without groups', :aggregate_failures do
            result = described_class.call(company.id, client.id, bank_detail_id, params_without_groups)

            expect(result).to be_success
            expect(result.data.versions.first.items.count).to eq(1)
            expect(result.data.versions.first.item_groups).to be_empty
          end
        end

        context 'when params are invalid' do
          context 'with missing required fields' do
            let(:invalid_params) { valid_params.except(:name) }

            it 'returns failure with validation errors', :aggregate_failures do
              result = described_class.call(company.id, client.id, bank_detail_id, invalid_params)

              expect(result).to be_failure
              expect(result.error).to be_a(Error::UnprocessableEntityError)
            end
          end

          context 'with invalid client_id' do
            it 'returns failure', :aggregate_failures do
              result = described_class.call(company.id, -1, bank_detail_id, valid_params)

              expect(result).to be_failure
              expect(result.error).to be_a(StandardError)
            end
          end

          context 'with invalid bank_detail_id' do
            it 'returns failure', :aggregate_failures do
              result = described_class.call(company.id, client.id, -1, valid_params)

              expect(result).to be_failure
              expect(result.error).to be_a(StandardError)
            end
          end

          context 'with invalid group references' do
            let(:params_with_invalid_group) do
              valid_params.deep_dup.tap do |params|
                params[:items].first[:group_uuid] = "non-existent-group"
              end
            end

            it 'rolls back the transaction' do
              expect {
                described_class.call(company.id, client.id, bank_detail_id, params_with_invalid_group)
              }.not_to change(Quote, :count)
            end
          end
        end

        context 'with transaction rollback' do
          before do
            allow(ProjectVersions::Create).to receive(:call).and_return(ServiceResult.failure(Error::UnprocessableEntityError))
          end

          it 'rolls back all changes' do
            expect {
              described_class.call(company.id, client.id, bank_detail_id, valid_params)
            }.not_to change(Quote, :count)
          end

          it 'returns failure', :aggregate_failures do
            result = described_class.call(company.id, client.id, bank_detail_id, valid_params)

            expect(result).to be_failure
            expect(result.error).to be_a(Error::UnprocessableEntityError)
          end
        end
      end
    end
  end
end
