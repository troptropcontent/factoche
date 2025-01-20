# TODO : Refactor this a little
class OpenApiDto
  ALLOWED_FIELD_TYPES = [ :string, :integer, :float, :boolean, :array, :object ].freeze
  @registered_dto_schemas = {}

  class << self
    attr_reader :registered_dto_schemas

    def register_schema(name, schema)
      @registered_dto_schemas[name] = schema
    end

    def field(name:, type:, subtype: nil, required: true)
      raise ArgumentError, "Invalid type: #{type}" unless ALLOWED_FIELD_TYPES.include?(type)

      validate_array_subtype!(name, type, subtype) if type == :array

      validate_object_subtype!(name, type, subtype) if type == :object

      fields[name] = { type: type, subtype: subtype, required: required }
      attr_reader name
      define_setter(name, type, subtype)


      OpenApiDto.register_schema(self.name, self.to_schema())
    end

    def fields
      @fields ||= {}
    end

    def to_schema
      {
        type: :object,
        required: fields.select { |_, info| info[:required] }.keys.map(&:to_s),
        properties: fields.transform_values do |info|
          case info[:type]
          when :array
            array_field_schema(info)
          when :object
            info[:subtype].is_a?(Array) ? { oneOf: info[:subtype].map { |subtype| { '$ref': "#/components/schemas/#{subtype.name}" } } } : { '$ref': "#/components/schemas/#{info[:subtype].name}" }
          else
            { type: info[:type] }.merge(info[:required] ? {} : { nullable: true })
          end
        end
      }
    end

    private

    def array_field_schema(info)
      return { type: :array, items: { '$ref': "#/components/schemas/#{info[:subtype].name}" } } unless info[:subtype].is_a?(Array)
      subtypes = info[:subtype]
      subtypes.first.is_a?(Array) ? { oneOf: subtypes.map { |subtype| { type: :array, items: { '$ref': "#/components/schemas/#{subtype.first.name}" }  } } } : { type: :array, items: { oneOf: subtypes.map { |subtype| { '$ref': "#/components/schemas/#{subtype.name}" } } } }
    end

    def validate_array_subtype!(name, type, subtype)
      raise ArgumentError, "Subtype is required for array" if subtype.nil?
      return if subtype.is_a?(Class) && subtype < OpenApiDto
      return if subtype.is_a?(Array) && subtype.all? { |sub| sub.is_a?(Class) && sub < OpenApiDto }
      return if subtype.is_a?(Array) && subtype.all? { |sub| sub.is_a?(Array) && sub.first.is_a?(Class) && sub.first < OpenApiDto }

      raise ArgumentError, "Subtype must be a class descendant of OpenApiDto or array of such classes or an array of one element arrays of such classes for #{name}"
    end

    def validate_object_subtype!(name, type, subtype)
      raise ArgumentError, "Subtype is required for array" if subtype.nil?
      return if subtype.is_a?(Class) && subtype < OpenApiDto
      return if subtype.is_a?(Array) && subtype.all? { |sub| sub.is_a?(Class) && sub < OpenApiDto }

      raise ArgumentError, "Subtype must be a class descendant of OpenApiDto or array of such classes for #{name}"
    end

    def define_setter(name, type, subtype)
      define_method("#{name}=") do |value|
        raise ArgumentError, "Nil value received for #{name} but it is required" if is_field_required?(name) && value.nil?
        validated_value = validate_field(name, type, subtype, value)
        instance_variable_set("@#{name}", validated_value)
      end
    end
  end

  def initialize(attributes = {})
    check_required_fields!(attributes)

    attributes.each do |key, value|
      if self.class.fields.key?(key.to_sym)
        send("#{key}=", value)
      else
        raise ArgumentError, "Unknown attribute #{key}"
      end
    end
  end

  private

  def validate_field(name, type, subtype, value)
    validated_value = nil
    case type
    when :string
      validated_value = validate_string_value!(value, name)
    when :integer
      validated_value = validate_integer_value!(value, name)
    when :float
      validated_value = validate_float_value!(value, name)
    when :boolean
      validated_value = validate_boolean_value!(value, name)
    when :array
      validated_value = validate_array_value!(value, name, subtype)
    when :object
      validated_value = validate_object_value!(value, name, subtype)
    else
      raise ArgumentError, "Unhandled field type: #{type} for #{name}"
    end
    validated_value
  end

  def check_required_fields!(attributes)
    missing_fields = self.class.fields
                          .select { |name, info| info[:required] && !attributes.key?(name) }
                          .keys
    unless missing_fields.empty?
      raise ArgumentError, "Missing required fields: #{missing_fields.join(', ')}"
    end
  end

  def is_field_required?(field_name)
    self.class.fields.dig(field_name, :required)
  end

  def validate_string_value!(value, field_name)
    if is_field_required?(field_name)
      raise ArgumentError, "Expected String for #{field_name}, got #{value.class}" unless value.is_a?(String)
    else
      raise ArgumentError, "Expected String or Nil for #{field_name}, got #{value.class}" unless value.is_a?(String) || value.nil?
    end
    value
  end

  def validate_integer_value!(value, field_name)
    if is_field_required?(field_name)
      raise ArgumentError, "Expected Integer for #{field_name}, got #{value.class}" unless value.is_a?(Integer)
    else
      raise ArgumentError, "Expected Integer or Nil for #{field_name}, got #{value.class}" unless value.is_a?(Integer) || value.nil?
    end
    value
  end

  def validate_float_value!(value, field_name)
    if is_field_required?(field_name)
      raise ArgumentError, "Expected Float for #{field_name}, got #{value.class}" unless value.is_a?(Float)
    else
      raise ArgumentError, "Expected Float or Nil for #{field_name}, got #{value.class}" unless value.is_a?(Float) || value.nil?
    end
    value
  end

  def validate_boolean_value!(value, field_name)
    if is_field_required?(field_name)
      raise ArgumentError, "Expected Boolean for #{field_name}, got #{value.class}" unless [ true, false ].include?(value)
    else
      raise ArgumentError, "Expected Boolean or Nil for #{field_name}, got #{value.class}" unless [ true, false ].include?(value) || value.nil?
    end
    value
  end

  def validate_array_value!(value, field_name, subtype)
    validate_array_type!(value, field_name)

    value.map { |item| create_subtype_instance(item, field_name, subtype) }
  end

  def validate_array_type!(value, field_name)
    if value.nil? && is_field_required?(field_name)
      raise ArgumentError, "Expected Array for #{field_name}, got nil"
    end
    unless value.is_a?(Array)
      raise ArgumentError, "Expected Array for #{field_name}, got #{value.class}"
    end
  end

  def create_subtype_instance(item, field_name, subtype)
    case subtype
    when Class
      subtype.new(item)
    when Array
      create_oneof_instance(item, field_name, subtype)
    else
      raise ArgumentError, "Invalid subtype configuration for #{field_name}"
    end
  end

  def create_oneof_instance(item, field_name, subtypes)
    return create_instance_from_class_list(item, subtypes) if subtypes.first.is_a?(Class)
    return create_instance_from_array_types(item, subtypes) if subtypes.first.is_a?(Array)

    raise ArgumentError, "Invalid subtype configuration for #{field_name}"
  end

  def create_instance_from_class_list(item, subtypes)
    subtypes.each do |subtype|
      return subtype.new(item)
    rescue ArgumentError
      next
    end
    raise ArgumentError, "No matching type found for item"
  end

  def create_instance_from_array_types(item, subtypes)
    subtypes.each do |subtype_array|
      return subtype_array.first.new(item)
    rescue ArgumentError
      next
    end
    raise ArgumentError, "No matching type found for item"
  end

  def validated_object_value(value, field_name, subtype)
    if is_field_required?(field_name)
      raise ArgumentError, "Expected Hash for #{field_name}, got #{value.class}" unless value.is_a?(Hash)
    else
      raise ArgumentError, "Expected Hash or Nil for #{field_name}, got #{value.class}" unless value.is_a?(Hash) || value.nil?
    end
    subtype.new(value)
  end
end
