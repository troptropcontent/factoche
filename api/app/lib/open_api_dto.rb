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

      if [ :array, :object ].include?(type)
        raise ArgumentError, "Subtype is required for #{type}" if subtype.nil?
        validate_subtype(name, type, subtype)
      end

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
            {
              type: :array,
              items: info[:subtype].is_a?(Array) ? { oneOf: info[:subtype].map { |subtype| { '$ref': "#/components/schemas/#{subtype.name}" } } } : { '$ref': "#/components/schemas/#{info[:subtype].name}" }
            }
          when :object
            info[:subtype].is_a?(Array) ? { oneOf: info[:subtype].map { |subtype| { '$ref': "#/components/schemas/#{subtype.name}" } } } : { '$ref': "#/components/schemas/#{info[:subtype].name}" }
          else
            { type: info[:type] }
          end
        end
      }
    end

    private

    def validate_subtype(name, type, subtype)
      unless (subtype.is_a?(Class) && subtype < OpenApiDto) ||
        (subtype.is_a?(Array) && subtype.all? { |sub| sub.is_a?(Class) && sub < OpenApiDto })
        raise ArgumentError, "Subtype must be a class descendant of OpenApiDto or array of such classes for #{name}"
      end
    end

    def define_setter(name, type, subtype)
      define_method("#{name}=") do |value|
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
    case type
    when :string
      raise ArgumentError, "Expected String for #{name}, got #{value.class}" unless value.is_a?(String)
    when :integer
      raise ArgumentError, "Expected Integer for #{name}, got #{value.class}" unless value.is_a?(Integer)
    when :float
      raise ArgumentError, "Expected Float for #{name}, got #{value.class}" unless value.is_a?(Float)
    when :boolean
      raise ArgumentError, "Expected Boolean for #{name}, got #{value.class}" unless [ true, false ].include?(value)
    when :array
      unless value.is_a?(Array)
        raise ArgumentError, "Expected Array for #{name}, got #{value.class}"
      end
      value.map! do |item|
        subtype_instance = nil
        if subtype.is_a?(Array)
          subtype.each do |sub|
            begin
              subtype_instance = sub.new(item)
              break
            rescue ArgumentError
              next
            end
          end
        else
          subtype_instance = subtype.new(item)
        end

        if subtype_instance.nil?
          raise ArgumentError, "No valid subtype match found for #{name} in #{value}"
        else
          subtype_instance
        end
      end
    when :object
      unless value.is_a?(Hash)
        raise ArgumentError, "Expected Hash for #{name}, got #{value.class}"
      end
      value = subtype.new(value)
    else
      raise ArgumentError, "Unhandled field type: #{type} for #{name}"
    end
    value
  end

  def check_required_fields!(attributes)
    missing_fields = self.class.fields
                          .select { |name, info| info[:required] && !attributes.key?(name) }
                          .keys
    unless missing_fields.empty?
      raise ArgumentError, "Missing required fields: #{missing_fields.join(', ')}"
    end
  end
end
