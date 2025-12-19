# TODO :
# - Refactor
# - Error handling
# - For :array & :object handle when the type is not a DTO (or dto variant, like string)
class OpenApiDto
  PRIMITIVE_TYPES = [ :string, :integer, :float, :boolean, :timestamp, :decimal ].freeze
  ADVANCED_TYPES = [ :array, :object, :enum ].freeze
  ALLOWED_FIELD_TYPES = PRIMITIVE_TYPES + ADVANCED_TYPES
  @registered_dto_schemas = {}

  class << self
    attr_reader :registered_dto_schemas

    def inherited(subclass)
      self.fields.each { |name, data|
        subclass.field(name, data[:type], subtype: data[:subtype], required: data[:required])
      }
    end

    def register_schema(name, schema)
      @registered_dto_schemas[name] = schema
    end

    def field(name, type, subtype: nil, required: true)
      raise ArgumentError, "Invalid type: #{type}" unless ALLOWED_FIELD_TYPES.include?(type)

      validate_array_subtype!(name, type, subtype) if type == :array

      validate_object_subtype!(name, type, subtype) if type == :object

      validate_enum_subtype!(name, type, subtype) if type == :enum

      fields[name] = { type: type, subtype: subtype, required: required }

      define_getters(name)

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
          base_type = case info[:type]
          when :array
            array_field_schema(info)
          when :object
            info[:subtype].is_a?(Array) ? { oneOf: info[:subtype].map { |subtype| { '$ref': "#/components/schemas/#{subtype.name}" } } } : { '$ref': "#/components/schemas/#{info[:subtype].name}" }
          when :enum
            {
              type: :string,
              enum: info[:subtype]
            }
          when :timestamp
            {
              type: :string,
              format: "date-time"
            }
          when :decimal
            {
              type: :string,
              format: "decimal"
            }
          else
            { type: info[:type] }
          end

          base_type.merge(info[:required] ? {} : { nullable: true })
        end
      }
    end

    private

    def array_field_schema(info)
      return { type: :array, items: { type: info[:subtype] } } if info[:subtype].is_a?(Symbol)
      return { type: :array, items: { '$ref': "#/components/schemas/#{info[:subtype].name}" } } unless info[:subtype].is_a?(Array)
      subtypes = info[:subtype]
      subtypes.first.is_a?(Array) ? { oneOf: subtypes.map { |subtype| { type: :array, items: { '$ref': "#/components/schemas/#{subtype.first.name}" }  } } } : { type: :array, items: { oneOf: subtypes.map { |subtype| { '$ref': "#/components/schemas/#{subtype.name}" } } } }
    end

    def validate_array_subtype!(name, type, subtype)
      raise ArgumentError, "Subtype is required for array" if subtype.nil?
      return if subtype.is_a?(Symbol) && PRIMITIVE_TYPES.include?(subtype)
      return if subtype.is_a?(Class) && subtype < OpenApiDto
      return if subtype.is_a?(Array) && subtype.all? { |sub| sub.is_a?(Class) && sub < OpenApiDto }
      return if subtype.is_a?(Array) && subtype.all? { |sub| sub.is_a?(Array) && sub.first.is_a?(Class) && sub.first < OpenApiDto }

      raise ArgumentError, "Subtype must be a primitive type symbol (:string, :decimal etc) or class descendant of OpenApiDto or and array such classes or an array of one element arrays of such classes for #{name}"
    end

    def validate_object_subtype!(name, type, subtype)
      raise ArgumentError, "Subtype is required for array" if subtype.nil?
      return if subtype.is_a?(Class) && subtype < OpenApiDto
      return if subtype.is_a?(Array) && subtype.all? { |sub| sub.is_a?(Class) && sub < OpenApiDto }

      raise ArgumentError, "Subtype must be a class descendant of OpenApiDto or array of such classes for #{name}"
    end

    def validate_enum_subtype!(name, type, subtype)
      raise ArgumentError, "Subtype is required for enum" if subtype.nil?
      return if subtype.is_a?(Array) && subtype.all? { |sub| sub.is_a?(String) }

      raise ArgumentError, "Subtype must be an array of strings for #{name}"
    end

    def define_setter(name, type, subtype)
      define_method("#{name}=") do |value|
        if value.nil?
          raise ArgumentError, "Nil value received for #{name} but it is required" if is_field_required?(name)
          instance_variable_set("@#{name}", nil)
        else
          validated_value = validate_field_value!(name, type, subtype, value)
          instance_variable_set("@#{name}", validated_value)
        end
      end
    end

    def define_getters(name)
      define_method(name) do
        instance_variable_get("@#{name}")
      end
      define_method("[]") do |arg|
        send(arg)
      end
    end
  end

  def initialize(base_object)
    if base_object.is_a?(Hash) || base_object.is_a?(ActionController::Parameters)
      self.class.fields.each do |field_name, info|
        value = base_object[field_name] || base_object[field_name.to_sym]
        send("#{field_name}=", value)
      end
    elsif base_object.class < ActiveRecord::Base || base_object.class < ActiveRecord::Relation
      self.class.fields.each do |field_name, info|
        value = load_value_from_object(base_object, field_name, info)
        send("#{field_name}=", value)
      end
    else
      raise ArgumentError, "Unhandled argument for initialization, handled types are hash or instance of ActiveRecord::Base"
    end
  end

  def fetch(attribute)
    send(attribute)
  end

  private

  def load_value_from_object(base_object, field_name, info)
    return base_object.send("#{field_name}?") if info[:type] == :boolean && field_name.starts_with?("is_")
    base_object.send(field_name)
  end

  def validate_field_value!(field_name, field_type, field_subtype, field_value)
    validated_field_value = nil
    case field_type
    when :string
      validated_field_value = validate_string_value!(field_value, field_name)
    when :integer
      validated_field_value = validate_integer_value!(field_value, field_name)
    when :float
      validated_field_value = validate_float_value!(field_value, field_name)
    when :boolean
      validated_field_value = validate_boolean_value!(field_value, field_name)
    when :timestamp
      validated_field_value = validate_timestamp_value!(field_value, field_name)
    when :decimal
      validated_field_value = validate_decimal_value!(field_value, field_name)
    when :array
      validated_field_value = validate_array_value!(field_value, field_name, field_subtype)
    when :object
      validated_field_value = validate_object_value!(field_value, field_name, field_subtype)
    when :enum
      validated_field_value = validate_enum_value!(field_value, field_name, field_subtype)
    else
      raise ArgumentError, "Unhandled field type: #{type} for #{field_name}"
    end
    validated_field_value
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
    return value if value.is_a?(Integer)
    begin
      return Integer(value, 10) if value.is_a?(String)
    rescue ArgumentError
      raise ArgumentError, "Expected an instance of Integer or a integer parsable instance of String for #{field_name}, got #{value}"
    end
    raise ArgumentError, "Expected an instance of Integer or a integer parsable instance of String for #{field_name}, got an instance #{value.class}"
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

  def validate_decimal_value!(value, field_name)
    return value if value.is_a?(BigDecimal)

    if value.is_a?(String)
      begin
        return BigDecimal(value)
      rescue ArgumentError
        raise ArgumentError, "Invalid decimal format for #{field_name}: #{value}"
      end
    end

    if value.is_a?(Integer)
      return BigDecimal(value)
    end

    raise ArgumentError, "Expected BigDecimal, Interger or string parsable as BigDecimal for #{field_name}, got #{value.class}"
  end

  def validate_timestamp_value!(value, field_name)
    return value if value.is_a?(ActiveSupport::TimeWithZone)

    if value.is_a?(String)
      begin
        return Time.zone.parse(value)
      rescue ArgumentError
        raise ArgumentError, "Invalid timestamp format for #{field_name}: #{value}"
      end
    end

    raise ArgumentError, "Expected ActiveSupport::TimeWithZone or timestamp string for #{field_name}, got #{value.class}"
  end

  def validate_array_value!(value, field_name, subtype)
    validate_array_type!(value, field_name)

    if subtype.is_a?(Symbol)
      begin
        value.map { |item| validate_field_value!(field_name, subtype, nil, item) }
      rescue ArgumentError
        raise ArgumentError, "Expected an array of #{subtype} for #{field_name}"
      end
    else
      value.map { |item| create_subtype_instance(item, field_name, subtype) }
    end
  end

  def validate_array_type!(value, field_name)
    raise ArgumentError, "Expected Array or an instance of ActiveRecord::Relatioon for #{field_name}, got an instance of #{value.class}" unless value.is_a?(Array) || value.class < ActiveRecord::Relation
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

  def validate_enum_value!(value, field_name, subtype)
    if is_field_required?(field_name)
      raise ArgumentError, "Expected an instance of String of one of the following values #{subtype.join(", ")} for #{field_name}, got an instance of #{value.class}#{value.is_a?(String) ? " with value #{value}":""}" unless value.is_a?(String) && subtype.include?(value)
    else
      raise ArgumentError, "Expected an instance of String of one of the following values #{subtype.join(", ")} or nil for #{field_name}, got an instance of #{value.class}" unless (value.is_a?(String) && subtype.include?(value)) || value.nil?
    end
    value
  end

  def validate_object_value!(value, field_name, subtype)
    raise ArgumentError, "Expected an Hash or a descendant of ActiveRecord::Base for #{field_name}, got an instance of #{value.class}" unless value.is_a?(Hash) || value.class < ActiveRecord::Base
    subtype.new(value)
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
