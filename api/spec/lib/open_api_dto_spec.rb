require 'spec_helper'

RSpec.describe OpenApiDto do
  describe "initialization" do
    describe "when the argument is an hash" do
      it "works" do
        tmp_class = Class.new(OpenApiDto) do
          field 'name', :string
        end
        expect(tmp_class.new({ name: 'toto' }).name).to eq('toto')
      end
    end

    describe "when the argument is a descendant of ActiveRecord" do
      it "works" do
        tmp_class = Class.new(OpenApiDto) do
          field 'name', :string
        end

        expect(tmp_class.new(Organization::Project.new(name: 'toto')).name).to eq('toto')
      end
    end

    describe "when the argument is neither an hash nor a descendant of ActiveRecord" do
      it "raises an error" do
        tmp_class = Class.new(OpenApiDto) do
          field 'name', :string
        end

        expect { tmp_class.new('toto') }.to raise_error(ArgumentError, 'Unhandled argument for initialization, handled types are hash or instance of ActiveRecord::Base')
      end
    end

    describe "when there is an issue with the type" do
      describe "when the type is string" do
        let(:tmp_dto_class) { Class.new(OpenApiDto) { field 'name', :string } }
        it "raises an error" do
          expect { tmp_dto_class.new({ name: 1 }) }.to raise_error(ArgumentError, 'Expected String for name, got Integer')
        end
      end
      describe "when the type is integer" do
        let(:tmp_dto_class) { Class.new(OpenApiDto) { field 'quantity', :integer } }
        it "raises an error" do
          expect { tmp_dto_class.new({ quantity: "b" }) }.to raise_error(ArgumentError, 'Expected Integer for quantity, got String')
        end
      end
      describe "when the type is float" do
        let(:tmp_dto_class) { Class.new(OpenApiDto) { field 'quantity', :float } }
        it "raises an error" do
          expect { tmp_dto_class.new({ quantity: 2 }) }.to raise_error(ArgumentError, 'Expected Float for quantity, got Integer')
        end
      end
      describe "when the type is boolean" do
        let(:tmp_dto_class) { Class.new(OpenApiDto) { field 'is_active', :boolean } }
        it "raises an error" do
          expect { tmp_dto_class.new({ is_active: 2 }) }.to raise_error(ArgumentError, 'Expected Boolean for is_active, got Integer')
        end
      end
      describe "when the type is timestamp" do
        let(:tmp_dto_class) { Class.new(OpenApiDto) { field 'created_at', :timestamp } }
        it "raises an error" do
          expect { tmp_dto_class.new({ created_at: 2 }) }.to raise_error(ArgumentError, 'Expected an instance of ActiveSupport::TimeWithZone for created_at, got an instance of Integer')
        end
      end
      describe "when the type is enum" do
        let(:tmp_dto_class) { Class.new(OpenApiDto) { field 'status', :enum, subtype: [ "new", "archived" ] } }
        describe "when the value is not a string" do
          it "raises an error" do
            expect { tmp_dto_class.new({ status: 2 }) }.to raise_error(ArgumentError, 'Expected an instance of String of one of the following values new, archived for status, got an instance of Integer')
          end
        end
        describe "when the value is a string but not one allowed" do
          it "raises an error" do
            expect { tmp_dto_class.new({ status: "cancelled" }) }.to raise_error(ArgumentError, 'Expected an instance of String of one of the following values new, archived for status, got an instance of String')
          end
        end
      end
      describe "when the type is array" do
        let(:tmp_dto_class) { Class.new(OpenApiDto) { field 'items', :array, subtype: Class.new(OpenApiDto) { field 'name', :string } } }

        describe "when the value is not an array" do
          it "raises an error" do
            expect { tmp_dto_class.new({ items: "" }) }.to raise_error(ArgumentError, 'Expected Array or an instance of ActiveRecord::Relatioon for items, got an instance of String')
          end
        end
        describe "when the value is an array but does not satisfy the subtype" do
          it "raises an error" do
            expect { tmp_dto_class.new({ items: [ { name: 3 } ] }) }.to raise_error(ArgumentError, 'Expected String for name, got Integer')
          end
        end
      end
      describe "when the type is object" do
        let(:tmp_dto_class) { Class.new(OpenApiDto) { field 'items', :object, subtype: Class.new(OpenApiDto) { field 'name', :string } } }

        describe "when the value is not an object" do
          it "raises an error" do
            expect { tmp_dto_class.new({ items: "" }) }.to raise_error(ArgumentError, 'Expected an Hash or a descendant of ActiveRecord::Base for items, got an instance of String')
          end
        end
        describe "when the value is an array but does not satisfy the subtype" do
          it "raises an error" do
            expect { tmp_dto_class.new({ items: { name: 3 } }) }.to raise_error(ArgumentError, 'Expected String for name, got Integer')
          end
        end
      end
    end
  end
end
