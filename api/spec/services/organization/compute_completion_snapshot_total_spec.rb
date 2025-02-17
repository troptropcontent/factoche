# typed: false

require 'rails_helper'
require "support/shared_contexts/organization/a_company_with_a_project_with_three_item_groups"

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Organization::ComputeCompletionSnapshotTotal do
  describe '.call' do
    include_context 'a company with a project with three item groups'

    let(:completion_snapshot) { FactoryBot.create(:completion_snapshot, project_version: project_version) }
    let(:project_version_first_item_group_item_quantity) { 1 }
    let(:project_version_first_item_group_item_unit_price_cents) { 100 }
    let(:project_version_second_item_group_item_quantity) { 2 }
    let(:project_version_second_item_group_item_unit_price_cents) { 200 }
    let(:project_version_third_item_group_item_quantity) { 3 }
    let(:project_version_third_item_group_item_unit_price_cents) { 300 }

    context 'when there are items with completion percentages' do
      before do
        FactoryBot.create(:completion_snapshot_item, completion_snapshot: completion_snapshot, item_id: project_version_first_item_group_item.id, completion_percentage: BigDecimal("0.10"))
        FactoryBot.create(:completion_snapshot_item, completion_snapshot: completion_snapshot, item_id: project_version_second_item_group_item.id, completion_percentage: BigDecimal("0.20"))
        FactoryBot.create(:completion_snapshot_item, completion_snapshot: completion_snapshot, item_id: project_version_third_item_group_item.id, completion_percentage: BigDecimal("0.30"))
      end

      it 'calculates the total correctly' do
        # Expected calculations:
        # Item1: 1 * 1€ * 10% = 0.10€
        # Item2: 2 * 2€ * 20% = 0.80€
        # Item3: 3 * 3€ * 30% = 2.70€
        # Total: 0.10€ + 0.80€ + 2.70€ = 3.60€
        expected_total = BigDecimal('3.60')

        result = described_class.call(completion_snapshot)
        expect(result).to eq(expected_total)
      end
    end

    context 'when some items have no completion snapshot items' do
      before do
        FactoryBot.create(:completion_snapshot_item, completion_snapshot: completion_snapshot, item_id: project_version_first_item_group_item.id, completion_percentage: BigDecimal("0.10"))
        FactoryBot.create(:completion_snapshot_item, completion_snapshot: completion_snapshot, item_id: project_version_second_item_group_item.id, completion_percentage: BigDecimal("0.20"))
      end

      it 'treats missing items as 0% complete' do
        # Expected calculations:
        # Item1: 1 * 1€ * 10% = 0.10€
        # Item2: 2 * 2€ * 20% = 0.80€
        # Item3: 3 * 3€ * 0% = 0€
        # Total: 0.10€ + 0.80€ = 0.90€
        expected_total = BigDecimal('0.90')
        result = described_class.call(completion_snapshot)
        expect(result).to eq(expected_total)
      end
    end

    context 'when completion_snapshot does not have all the relevant dependencies' do
      before do
        completion_snapshot.project_version = nil
      end

      it 'raises an UnprocessableEntityError' do
        expect {
          described_class.call(completion_snapshot)
        }.to raise_error(Error::UnprocessableEntityError, "Project version is not defined")
      end
    end
  end
end
