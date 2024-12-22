# Common schema definitions for API error responses
module ApiError
  def self.schema
    {
      type: :object,
      additionalProperties: false,
      properties: {
        error: {
          type: :object,
          additionalProperties: false,
          properties: {
            status: { type: :string },
            code: { type: :integer },
            message: { type: :string },
            details: { type: :object, nullable: true }
          },
          required: [ 'status', 'code', 'message', 'details' ]
        }
      },
      required: [ 'error' ]
    }
  end
end
