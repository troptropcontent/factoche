# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/MultipleExpectations
RSpec.describe Organization::Discounts::CalculateAmounts do
  describe '.call' do
    context 'with a single fixed amount discount' do
      it 'applies the fixed discount' do
        result = described_class.call(
          items_total: '10000'.to_d,
          discounts: [ { kind: 'fixed_amount', value: 30, position: 1 } ]
        )

        expect(result.success?).to be true
        expect(result.data[:final_total]).to eq('9970'.to_d)
        expect(result.data[:total_discount]).to eq('30'.to_d)
        expect(result.data[:discounts][0][:amount]).to eq('30'.to_d)
        expect(result.data[:discounts][0][:running_total_after]).to eq('9970'.to_d)
      end

      it 'caps fixed discount at the running total' do
        result = described_class.call(
          items_total: '100'.to_d,
          discounts: [ { kind: 'fixed_amount', value: 200, position: 1 } ]
        )

        expect(result.success?).to be true
        expect(result.data[:final_total]).to eq('0'.to_d)
        expect(result.data[:total_discount]).to eq('100'.to_d)
        expect(result.data[:discounts][0][:amount]).to eq('100'.to_d)
      end
    end

    context 'with a single percentage discount' do
      it 'applies the percentage discount' do
        result = described_class.call(
          items_total: '10000'.to_d,
          discounts: [ { kind: 'percentage', value: 0.25, position: 1 } ]
        )

        expect(result.success?).to be true
        expect(result.data[:final_total]).to eq('7500'.to_d)
        expect(result.data[:total_discount]).to eq('2500'.to_d)
        expect(result.data[:discounts][0][:amount]).to eq('2500'.to_d)
        expect(result.data[:discounts][0][:running_total_after]).to eq('7500'.to_d)
      end
    end

    context 'with multiple discounts applied sequentially' do
      it 'applies fixed discount then percentage discount' do
        result = described_class.call(
          items_total: '10000'.to_d,
          discounts: [
            { kind: 'fixed_amount', value: 30, position: 1 },
            { kind: 'percentage', value: 0.25, position: 2 }
          ]
        )

        expect(result.success?).to be true

        # First discount: 10000 - 30 = 9970
        expect(result.data[:discounts][0][:amount]).to eq('30'.to_d)
        expect(result.data[:discounts][0][:running_total_after]).to eq('9970'.to_d)

        # Second discount: 9970 * 0.25 = 2492.50
        expect(result.data[:discounts][1][:amount]).to eq('2492.50'.to_d)
        expect(result.data[:discounts][1][:running_total_after]).to eq('7477.50'.to_d)

        # Final totals
        expect(result.data[:final_total]).to eq('7477.50'.to_d)
        expect(result.data[:total_discount]).to eq('2522.50'.to_d)
      end

      it 'applies percentage discount then fixed discount' do
        result = described_class.call(
          items_total: '10000'.to_d,
          discounts: [
            { kind: 'percentage', value: 0.20, position: 1 },
            { kind: 'fixed_amount', value: 100, position: 2 }
          ]
        )

        expect(result.success?).to be true

        # First discount: 10000 * 0.20 = 2000
        expect(result.data[:discounts][0][:amount]).to eq('2000'.to_d)
        expect(result.data[:discounts][0][:running_total_after]).to eq('8000'.to_d)

        # Second discount: 8000 - 100 = 7900
        expect(result.data[:discounts][1][:amount]).to eq('100'.to_d)
        expect(result.data[:discounts][1][:running_total_after]).to eq('7900'.to_d)

        # Final totals
        expect(result.data[:final_total]).to eq('7900'.to_d)
        expect(result.data[:total_discount]).to eq('2100'.to_d)
      end

      it 'applies three discounts sequentially' do
        result = described_class.call(
          items_total: '10000'.to_d,
          discounts: [
            { kind: 'fixed_amount', value: 500, position: 1 },
            { kind: 'percentage', value: 0.10, position: 2 },
            { kind: 'fixed_amount', value: 50, position: 3 }
          ]
        )

        expect(result.success?).to be true

        # First: 10000 - 500 = 9500
        expect(result.data[:discounts][0][:amount]).to eq('500'.to_d)
        expect(result.data[:discounts][0][:running_total_after]).to eq('9500'.to_d)

        # Second: 9500 * 0.10 = 950
        expect(result.data[:discounts][1][:amount]).to eq('950'.to_d)
        expect(result.data[:discounts][1][:running_total_after]).to eq('8550'.to_d)

        # Third: 8550 - 50 = 8500
        expect(result.data[:discounts][2][:amount]).to eq('50'.to_d)
        expect(result.data[:discounts][2][:running_total_after]).to eq('8500'.to_d)

        # Final totals
        expect(result.data[:final_total]).to eq('8500'.to_d)
        expect(result.data[:total_discount]).to eq('1500'.to_d)
      end
    end

    context 'with discounts in wrong order' do
      it 'applies discounts in position order, not array order' do
        result = described_class.call(
          items_total: '1000'.to_d,
          discounts: [
            { kind: 'percentage', value: 0.10, position: 2 },
            { kind: 'fixed_amount', value: 50, position: 1 }
          ]
        )

        expect(result.success?).to be true

        # Should apply position 1 first: 1000 - 50 = 950
        expect(result.data[:discounts][0][:amount]).to eq('50'.to_d)
        expect(result.data[:discounts][0][:running_total_after]).to eq('950'.to_d)

        # Then position 2: 950 * 0.10 = 95
        expect(result.data[:discounts][1][:amount]).to eq('95'.to_d)
        expect(result.data[:discounts][1][:running_total_after]).to eq('855'.to_d)
      end
    end

    context 'with string keys (from hash context)' do
      it 'works with string keys instead of symbol keys' do
        result = described_class.call(
          items_total: '1000'.to_d,
          discounts: [
            { "kind" => 'fixed_amount', "value" => 100, "position" => 1 }
          ]
        )

        expect(result.success?).to be true
        expect(result.data[:final_total]).to eq('900'.to_d)
        expect(result.data[:total_discount]).to eq('100'.to_d)
      end
    end

    context 'with zero items total' do
      it 'returns zero for all amounts' do
        result = described_class.call(
          items_total: '0'.to_d,
          discounts: [ { kind: 'percentage', value: 0.25, position: 1 } ]
        )

        expect(result.success?).to be true
        expect(result.data[:final_total]).to eq('0'.to_d)
        expect(result.data[:total_discount]).to eq('0'.to_d)
      end
    end

    context 'with no discounts' do
      it 'returns the original total' do
        result = described_class.call(items_total: '10000'.to_d, discounts: [])

        expect(result.success?).to be true
        expect(result.data[:final_total]).to eq('10000'.to_d)
        expect(result.data[:total_discount]).to eq('0'.to_d)
        expect(result.data[:discounts]).to be_empty
      end
    end

    context 'with invalid discount kind' do
      it 'returns an error' do
        result = described_class.call(
          items_total: '1000'.to_d,
          discounts: [ { kind: 'invalid_type', value: 100, position: 1 } ]
        )

        expect(result.failure?).to be true
        expect(result.error).to be_a(Error::UnprocessableEntityError)
        expect(result.error.message).to include('must be one of: percentage, fixed_amount')
      end
    end
  end
end
# rubocop:enable RSpec/MultipleExpectations
