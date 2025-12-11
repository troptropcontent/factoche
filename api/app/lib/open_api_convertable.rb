module OpenApiConvertable
  def location
    @location ||= Object.const_source_location(name)[0]
  end

  def open_api_schema
    @schema ||= OpenApiSchemaBuilder.build(location)
  end
end
