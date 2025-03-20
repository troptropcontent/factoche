module Organization
  module Quotes
    class Create
      class << self
        def call(company_id, client_id, params)
          validated_params = validate_params!(params)

          ensure_valid_item_group_uuid!(validated_params)

          ensure_each_group_is_used!(validated_params)

          ActiveRecord::Base.transaction do
            quote = create_quote(company_id, client_id, validated_params)
            version = create_version(quote, validated_params)
            create_items_structure(version, validated_params)

            ServiceResult.success(quote)
          end
        rescue StandardError => e
          ServiceResult.failure(e)
        end

        private

        def validate_params!(params)
          contract = Organization::Quotes::CreateContract.new
          result = contract.call(params)
          raise Error::UnprocessableEntityError.new(result.errors.to_h) if result.failure?
          result.to_h
        end

        def create_quote(company_id, client_id, validated_params)
          Organization::Quote.create!(
            company_id: company_id,
            client_id: client_id,
            number: find_next_quote_number!(company_id),
            name: validated_params[:name],
            description: validated_params[:description]
          )
        end

        def create_version(quote, validated_params)
          Organization::ProjectVersion.create!(
            project: quote,
            retention_guarantee_rate: validated_params[:retention_guarantee_rate]
          )
        end

        def create_items_structure(version, validated_params)
          if validated_params[:groups].present?
            create_groups_with_items(version, validated_params)
          else
            create_standalone_items(version, validated_params)
          end
        end

        def create_groups_with_items(version, validated_params)
          validated_params[:groups].each do |group_input|
            group = Organization::ItemGroup.create!({
              name: group_input[:name],
              description: group_input[:description],
              position: group_input[:position],
              project_version: version
            })

            validated_params[:items].filter { |item_input| item_input[:group_uuid] === group_input[:uuid] }.each do |item_input|
              Organization::Item.create!(build_item_attribute_from_input(item_input, version, group).merge({
                item_group: group
              }))
            end
          end
        end

        def create_standalone_items(version, validated_params)
          validated_params[:items].each do |item_input|
            Organization::Item.create!(build_item_attribute_from_input(item_input, version))
          end
        end

        def build_item_attribute_from_input(input, version, group = nil)
          {
            original_item_uuid: SecureRandom.uuid,
            name: input[:name],
            description: input[:description],
            position: input[:position],
            quantity: input[:quantity],
            unit: input[:unit],
            unit_price_amount: input[:unit_price_amount],
            tax_rate: input[:tax_rate],
            project_version: version,
            item_group: group
          }
        end

        def ensure_valid_item_group_uuid!(params)
          return if params[:groups].blank?

          valid_group_uuids = params[:groups].map { |g| g[:uuid] }.to_set
          invalid_items = params[:items].reject { |item| valid_group_uuids.include?(item[:group_uuid]) }

          if invalid_items.any?
            invalid_references = invalid_items.map { |item|
              "Item '#{item[:name]}' references non-existent group '#{item[:group_uuid]}'"
            }.join(", ")

            raise Error::UnprocessableEntityError.new(
              "Invalid group references found: #{invalid_references}"
            )
          end
        end

        def ensure_each_group_is_used!(params)
          return if params[:groups].blank?

          used_group_uuids = params[:items].map { |i| i[:group_uuid] }.to_set
          unused_groups = params[:groups].reject { |group| used_group_uuids.include?(group[:uuid]) }

          if unused_groups.any?
            unused_group_names = unused_groups.map { |g| "'#{g[:name]}'" }.join(", ")
            raise Error::UnprocessableEntityError.new(
              "Found empty groups with no items: #{unused_group_names}"
            )
          end
        end

        def find_next_quote_number!(company_id)
          r = Projects::FindNextNumber.call(company_id, Quote)
          raise r.error if r.failure?

          r.data
        end
      end
    end
  end
end
