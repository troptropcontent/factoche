module ApplicationService
  extend ActiveSupport::Concern

  class_methods do
    def call(...)
      result = new.call(...)
      result.is_a?(ServiceResult) ? result : success(result)
    rescue StandardError => e
      failure(e)
    end

    def contract(contract_class)
      @contract_class = contract_class
    end

    def contract_class
      @contract_class
    end

    private

    def success(data = nil)
      ServiceResult.new(data: data, success: true)
    end

    def failure(error)
      ServiceResult.new(error: error, success: false)
    end
  end

  def validate!(params, contract_class = self.class.contract_class)
    return params unless contract_class

    contract = contract_class.new
    result = contract.call(params)
    raise Error::UnprocessableEntityError.new(result.errors.to_h) if result.failure?
    result.to_h.with_indifferent_access
  end

  def transaction(&block)
    ActiveRecord::Base.transaction(&block)
  end

  def success(data = nil)
    self.class.send(:success, data)
  end

  def failure(error)
    self.class.send(:failure, error)
  end
end
