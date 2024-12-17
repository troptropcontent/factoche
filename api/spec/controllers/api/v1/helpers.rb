# Common schema definitions for API error responses
module ApiError
  def self.schema
    {
      type: :object,
      properties: {
        error: {
          type: :object,
          properties: {
            status: { type: :string },
            code: { type: :integer },
            message: { type: :string }
          },
          required: [ 'status', 'code', 'message' ]
        }
      },
      required: [ 'error' ]
    }
  end
end
