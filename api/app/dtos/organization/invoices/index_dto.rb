module Organization
  module Invoices
    class Meta < OpenApiDto
      field "order_versions", :array, subtype: Organization::ProjectVersions::CompactDto
      field "orders", :array, subtype: Organization::Projects::Orders::CompactDto
    end
    class IndexDto < OpenApiDto
      field "results", :array, subtype: CompactDto
      field "meta", :object, subtype: Meta
    end
  end
end
