require 'rails_helper'

RSpec.describe ServiceResult do
  let(:success_data) { "some data" }
  let(:error_message) { "something went wrong" }

  describe ".success" do
    subject(:result) { described_class.success(success_data) }

    it "creates a successful result", :aggregate_failures do
      expect(result).to be_success
      expect(result).not_to be_failure
    end

    it "stores the data" do
      expect(result.data).to eq(success_data)
    end

    it "has no error" do
      expect(result.error).to be_nil
    end
  end

  describe ".failure" do
    subject(:result) { described_class.failure(error_message) }

    it "creates a failure result", :aggregate_failures do
      expect(result).to be_failure
      expect(result).not_to be_success
    end

    it "stores the error" do
      expect(result.error).to eq(error_message)
    end

    it "has no data" do
      expect(result.data).to be_nil
    end
  end

  describe "#on_success" do
    context "when successful" do
      subject(:result) { described_class.success(success_data) }

      it "yields the data to the block" do
        expect { |b| result.on_success(&b) }.to yield_with_args(success_data)
      end

      it "returns self" do
        expect(result.on_success { |data| data }).to eq(result)
      end

      it "doesn't yield if no block given" do
        expect { result.on_success }.not_to raise_error
      end
    end

    context "when failure" do
      subject(:result) { described_class.failure(error_message) }

      it "doesn't yield to the block" do
        expect { |b| result.on_success(&b) }.not_to yield_control
      end

      it "returns self" do
        expect(result.on_success { |data| data }).to eq(result)
      end
    end
  end

  describe "#on_failure" do
    context "when failure" do
      subject(:result) { described_class.failure(error_message) }

      it "yields the error to the block" do
        expect { |b| result.on_failure(&b) }.to yield_with_args(error_message)
      end

      it "returns self" do
        expect(result.on_failure { |error| error }).to eq(result)
      end

      it "doesn't yield if no block given" do
        expect { result.on_failure }.not_to raise_error
      end
    end

    context "when successful" do
      subject(:result) { described_class.success(success_data) }

      it "doesn't yield to the block" do
        expect { |b| result.on_failure(&b) }.not_to yield_control
      end

      it "returns self" do
        expect(result.on_failure { |error| error }).to eq(result)
      end
    end
  end

  describe "chaining" do
    subject(:result) { described_class.success(success_data) }

    it "allows chaining of on_success and on_failure", :aggregate_failures do
      success_called = false
      failure_called = false

      result
        .on_success { success_called = true }
        .on_failure { failure_called = true }

      expect(success_called).to be true
      expect(failure_called).to be false
    end
  end
end
