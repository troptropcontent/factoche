require "ripper"

class ContractParser
  def self.parse_file(file_path)
    source = File.read(file_path)
    new(source).parse
  end

  def initialize(source)
    @source = source
    @schema_definitions = []
  end

  def parse
    sexp = Ripper.sexp(@source)
    find_params_block(sexp)
    @schema_definitions
  end

  private

  def find_params_block(node)
    return unless node.is_a?(Array)

    # Look for method_add_block with params
    if node[0] == :method_add_block
      method_call = node[1]
      if method_call.is_a?(Array) && is_params_call?(method_call)
        # Found the params block
        do_block = node[2]
        if do_block && do_block[0] == :do_block
          extract_params_body(do_block)
        end
        return
      end
    end

    # Recursively search
    node.each { |child| find_params_block(child) }
  end

  def is_params_call?(node)
    return false unless node.is_a?(Array)

    case node[0]
    when :method_add_arg
      fcall = node[1]
      return fcall.is_a?(Array) && fcall[0] == :fcall && fcall[1].is_a?(Array) && fcall[1][1] == "params"
    when :fcall
      return node[1].is_a?(Array) && node[1][1] == "params"
    end

    false
  end

  def extract_params_body(do_block)
    # do_block structure: [:do_block, params, [:bodystmt, statements, ...]]
    body = do_block[2]
    return unless body && body[0] == :bodystmt

    statements = body[1]
    extract_statements(statements, depth: 0, parent: nil)
  end

  def extract_statements(statements, depth:, parent:)
    return unless statements.is_a?(Array)

    statements.each do |stmt|
      case stmt[0]
      when :method_add_arg, :call
        # Simple field definition like required(:email).value(:string)
        # or optional(:metadata).hash
        field_info = parse_method_chain(stmt, depth: depth, parent: parent)
        @schema_definitions << field_info if field_info
      when :method_add_block
        # Field with nested block like required(:settings).hash do...end
        field_info = parse_method_chain(stmt[1], depth: depth, parent: parent, has_block: true)
        if field_info
          @schema_definitions << field_info

          # Extract nested fields with this field as their parent
          nested_block = stmt[2]
          if nested_block && nested_block[0] == :do_block
            nested_body = nested_block[2]
            if nested_body && nested_body[0] == :bodystmt
              extract_statements(nested_body[1], depth: depth + 1, parent: field_info[:name])
            end
          end
        end
      end
    end
  end

  def parse_method_chain(node, depth:, parent:, has_block: false)
    # Extract the base method (required/optional)
    base_method = find_base_method(node)
    return nil unless base_method && [ "required", "optional" ].include?(base_method)

    # Extract field name (symbol argument to required/optional)
    field_name = find_field_name(node)
    return nil unless field_name

    # Extract type information (.value, .array, .hash, etc.)
    type_info = find_type_info(node, has_block: has_block)

    {
      required: base_method == "required",
      name: field_name,
      type: type_info[:type],
      sub_type: type_info[:sub_type],
      has_nested: type_info[:has_nested],
      depth: depth,
      parent: parent
    }
  end

  def find_base_method(node)
    return nil unless node.is_a?(Array)

    case node[0]
    when :method_add_arg, :call
      return find_base_method(node[1])
    when :fcall
      ident = node[1]
      return ident[1] if ident && ident[0] == :@ident
    end

    nil
  end

  def find_field_name(node)
    symbols = find_all_symbols(node)
    symbols.first  # The first symbol is the field name
  end

  def find_all_symbols(node, symbols = [])
    return symbols unless node.is_a?(Array)

    if node[0] == :symbol_literal
      symbol_node = node[1]
      if symbol_node && symbol_node[0] == :symbol
        ident = symbol_node[1]
        if ident && ident[0] == :@ident
          symbols << ident[1]
        end
      end
    end

    node.each { |child| find_all_symbols(child, symbols) }
    symbols
  end

  def find_type_info(node, has_block: false)
    # Look for method calls like .value(:string), .filled(:string), .array(:string), .hash
    type_method = find_type_method_name(node)

    case type_method
    when "value", "filled"
      # Both .value() and .filled() take the same type argument
      # .filled() additionally ensures the value is not nil/empty
      symbols = find_all_symbols(node)
      type_value = symbols[1]  # First symbol is field name, second is type
      { type: type_value, sub_type: nil, has_nested: false }
    when "array"
      symbols = find_all_symbols(node)
      sub_type = symbols[1]  # Type of array items
      { type: "array", sub_type: sub_type, has_nested: has_block }
    when "hash"
      { type: "hash", sub_type: nil, has_nested: has_block }
    else
      # No type specified, default to string
      { type: nil, sub_type: nil, has_nested: false }
    end
  end

  def find_type_method_name(node)
    return nil unless node.is_a?(Array)

    case node[0]
    when :call
      # [:call, receiver, period, method_name]
      method_name = node[3]
      if method_name && method_name[0] == :@ident
        return method_name[1]
      end
      # Continue searching in receiver
      find_type_method_name(node[1])
    when :method_add_arg
      find_type_method_name(node[1])
    else
      node.each do |child|
        result = find_type_method_name(child)
        return result if result
      end
      nil
    end
  end
end
