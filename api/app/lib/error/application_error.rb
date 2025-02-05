module Error
  # Base module for defining error attributes
  module ErrorAttributes
    def code(value = nil)
      return @code unless value
      @code = value
    end

    def message(value = nil)
      return @message unless value
      @message = value
    end

    def status(value = nil)
      return @status unless value
      @status = value
    end
  end

  # Base class for all application errors
  class ApplicationError < StandardError
    extend ErrorAttributes
  end
end
