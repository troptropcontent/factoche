require_relative "contract_parser"

class OpenApiSchemaBuilder
  # Maps dry-validation types to OpenAPI type (and optionally format)
  # See: https://swagger.io/specification/#data-types
  TYPE_MAPPING = {
    "string" => :string,
    "integer" => { type: :integer, format: "int32" },
    "int" => { type: :integer, format: "int32" },
    "float" => { type: :number, format: "float" },
    "decimal" => { type: :number, format: "double" },
    "number" => { type: :number, format: "double" },
    "bool" => :boolean,
    "boolean" => :boolean,
    "date" => { type: :string, format: "date" },
    "time" => { type: :string, format: "date-time" },
    "date_time" => { type: :string, format: "date-time" },
    "array" => :array,
    "hash" => :object
  }.freeze

  def self.build(contract_file_path)
    new(contract_file_path).build
  end

  def initialize(contract_file_path)
    @contract_file_path = contract_file_path
    @definitions = []
  end

  def build
    @definitions = ContractParser.parse_file(@contract_file_path)
    build_schema(@definitions)
  end

  private

  def build_schema(definitions, depth = 0, parent = nil)
    schema = {
      type: :object,
      properties: {},
      required: []
    }

    # Group definitions by depth and parent to handle nesting
    current_level = definitions.select { |d| d[:depth] == depth && d[:parent] == parent }

    current_level.each do |field|
      property_schema = build_property_schema(field, definitions, depth)
      schema[:properties][field[:name].to_sym] = property_schema
      schema[:required] << field[:name] if field[:required]
    end

    # Clean up empty required array
    schema.delete(:required) if schema[:required].empty?

    schema
  end

  def build_property_schema(field, all_definitions, current_depth)
    case field[:type]
    when "array"
      build_array_schema(field, all_definitions, current_depth)
    when "hash"
      build_hash_schema(field, all_definitions, current_depth)
    else
      build_simple_schema(field)
    end
  end

  def build_simple_schema(field)
    type_info = TYPE_MAPPING[field[:type]] || :string

    # type_info can be either a symbol (:string) or a hash ({type: :integer, format: 'int32'})
    if type_info.is_a?(Hash)
      type_info.dup  # Return a copy to avoid modifying the frozen hash
    else
      { type: type_info }
    end
  end

  def build_array_schema(field, all_definitions, current_depth)
    schema = { type: :array }

    if field[:has_nested]
      # Array items have nested schema (e.g., array of objects with defined properties)
      # Filter by both depth and parent to get only this array's nested fields
      nested_fields = all_definitions.select { |d| d[:depth] == current_depth + 1 && d[:parent] == field[:name] }

      if nested_fields.any?
        # Build nested schema for array items
        nested_schema = build_schema(all_definitions, current_depth + 1, field[:name])
        schema[:items] = nested_schema
      else
        # Has nested block but no fields found - default to object
        type_info = TYPE_MAPPING[field[:sub_type]] || :object
        schema[:items] = type_info.is_a?(Hash) ? type_info.dup : { type: type_info }
      end
    elsif field[:sub_type]
      # Simple array with specified item type
      type_info = TYPE_MAPPING[field[:sub_type]] || :string
      schema[:items] = type_info.is_a?(Hash) ? type_info.dup : { type: type_info }
    end

    schema
  end

  def build_hash_schema(field, all_definitions, current_depth)
    if field[:has_nested]
      # Find nested fields for this specific hash (filter by parent)
      nested_fields = all_definitions.select { |d| d[:depth] == current_depth + 1 && d[:parent] == field[:name] }

      if nested_fields.any?
        # Build nested schema
        nested_schema = build_schema(all_definitions, current_depth + 1, field[:name])
        return nested_schema
      end
    end

    # Empty hash or hash without nested definition
    { type: :object }
  end
end
