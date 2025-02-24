
class ServiceResult
  attr_reader :data, :error

  def self.success(data = nil)
    new(success: true, data: data)
  end

  def self.failure(error)
    new(success: false, error: error)
  end

  def initialize(success:, data: nil, error: nil)
    @success = success
    @data = data
    @error = error
  end

  def success?
    @success
  end

  def failure?
    !success?
  end

  def on_success
    yield(data) if success? && block_given?
    self
  end

  def on_failure
    yield(error) if failure? && block_given?
    self
  end
end
