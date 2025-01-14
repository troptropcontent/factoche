require 'spec_helper'

RSpec.describe OpenApiDto, focus: true do
  class TestItemDto < OpenApiDto
    field name: :name, type: :string
    field name: :quantity, type: :integer
    field name: :unit, type: :string, required: false
  end

  class TestProjectDto < OpenApiDto
    field name: :name, type: :string
    field name: :items, type: :array, subtype: TestItemDto
  end

  describe '.field' do
    it 'defines attributes with the correct type' do
      expect(TestItemDto.fields).to include(:name, :quantity, :unit)
      expect(TestItemDto.fields[:name][:type]).to eq(:string)
      expect(TestItemDto.fields[:quantity][:type]).to eq(:integer)
    end

    it 'raises an error for unsupported types' do
      expect {
        Class.new(OpenApiDto) do
          field name: :invalid, type: :unsupported
        end
      }.to raise_error(ArgumentError, /Invalid type/)
    end

    it 'requires a subtype for arrays and objects' do
      expect {
        Class.new(OpenApiDto) do
          field name: :invalid_array, type: :array
        end
      }.to raise_error(ArgumentError, /Subtype is required/)
    end
  end

  describe '#initialize' do
    it 'assigns attributes correctly' do
      item = TestItemDto.new(name: 'Bolt', quantity: 10)
      expect(item.name).to eq('Bolt')
      expect(item.quantity).to eq(10)
      expect(item.unit).to be_nil # Optional field
    end

    it 'raises an error for unknown attributes' do
      expect {
        TestItemDto.new(name: 'name', quantity: 0, unknown: 'value')
      }.to raise_error(ArgumentError, /Unknown attribute/)
    end

    it 'raises an error for missing required fields' do
      expect {
        TestItemDto.new(quantity: 10)
      }.to raise_error(ArgumentError, /Missing required fields: name/)
    end
  end

  describe 'nested DTOs' do
    it 'creates nested DTOs for arrays' do
      project_dto = TestProjectDto.new(name: 'Test Project', items: [ { name: 'Screw', quantity: 5 } ])
      expect(project_dto.name).to eq('Test Project')
      expect(project_dto.items).to all(be_a(TestItemDto))
      expect(project_dto.items.first.name).to eq('Screw')
      expect(project_dto.items.first.quantity).to eq(5)
    end

    it 'raises an error for invalid nested array elements' do
      expect {
        TestProjectDto.new(name: 'Test Project', items: [ { invalid: 'value' } ])
      }.to raise_error(ArgumentError, /Missing required fields: name, quantity/)
    end
  end

  describe 'custom validations' do
    it 'validates string fields' do
      expect {
        TestItemDto.new(name: 123, quantity: 10)
      }.to raise_error(ArgumentError, /Expected String for name, got Integer/)
    end

    it 'validates integer fields' do
      expect {
        TestItemDto.new(name: 'Bolt', quantity: 'not an integer')
      }.to raise_error(ArgumentError, /Expected Integer for quantity, got String/)
    end

    it 'validates array subtypes' do
      expect {
        TestProjectDto.new(name: 'Test Project', items: 'not an array')
      }.to raise_error(ArgumentError, /Expected Array for items, got String/)
    end
  end

  describe "register schema into OpenApiDto" do
    class TestNestedDto < OpenApiDto
      field name: :test_field, type: :string
    end
    class OtherNestedDto < OpenApiDto
      field name: :test_field, type: :string
    end

    class TestDto < OpenApiDto
      field name: :test_field, type: :string
      field name: :nested_dto, type: :object, subtype: [ TestNestedDto, OtherNestedDto ]
    end

    it 'registers schemas for subclasses' do
      expect(OpenApiDto.registered_dto_schemas).to have_key('TestDto')
      expect(OpenApiDto.registered_dto_schemas['TestDto']).to eq({
        type: :object,
        required: [ 'test_field', 'nested_dto' ],
        properties: {
          test_field: { type: :string },
          nested_dto: {
            oneOf: [
              { :$ref =>"#/components/schemas/TestNestedDto" },
              { :$ref=>"#/components/schemas/OtherNestedDto" }
            ]
          }
        }
      })
    end
  end
end
