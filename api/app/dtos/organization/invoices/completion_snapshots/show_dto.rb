module Organization
  module Invoices
    module CompletionSnapshots
      class ShowDto < OpenApiDto
        field "result", :object, subtype: ExtendedDto
      end
    end
  end
end
