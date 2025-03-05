module Organization
  module Projects
    class InvoicedItemDto < OpenApiDto
      field "original_item_uuid", :string
      field "invoiced_amount", :decimal
    end
    class InvoicedItemsDto < OpenApiDto
      field "results", :array, subtype: InvoicedItemDto
    end
  end
end
