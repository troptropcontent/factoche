class Organization::CreateProject
  class << self
    def call(create_project_dto)
      ActiveRecord::Base.transaction do
        project = create_project!(create_project_dto)
        version = create_version!(project, create_project_dto)
        create_items!(version, create_project_dto.items)
        project
      rescue ActiveRecord::RecordInvalid => e
        raise e
      end
    end

    private

    def create_project!(dto)
      Organization::Project.create!(
        name: dto.name,
        client_id: dto.client_id
      )
    end

    def create_version!(project, dto)
      project.project_versions.create!(
        retention_guarantee_rate: dto.retention_guarantee_rate
      )
    end

    def create_items!(version, items)
      item_type = find_item_type!(items)
      if item_type == :item_group
        create_item_groups!(version, items)
      else
        create_simple_items!(version, items)
      end
    end

    def create_item_groups!(version, item_groups)
      version.item_groups.create!(item_groups.map { |group_dto|
        {
          project_version_id: version.id,
          name: group_dto.name,
          description: group_dto.description,
          position: group_dto.position,
          items_attributes: build_items_attributes(version, group_dto.items)
        }
      })
    end

    def create_simple_items!(version, items)
      version.items.create!(items.map { |item_dto|
        build_item_attributes(item_dto)
      })
    end

    def build_items_attributes(version, items)
      items.map { |item_dto|
        build_item_attributes(item_dto).merge(project_version: version)
      }
    end

    def build_item_attributes(item_dto)
      {
        name: item_dto.name,
        description: item_dto.description,
        position: item_dto.position,
        unit: item_dto.unit,
        unit_price_cents: item_dto.unit_price_cents,
        quantity: item_dto.quantity
      }
    end

    def find_item_type!(item_dtos)
      item_types = item_dtos.map(&:class).uniq
      if item_types.length > 1
        raise Error::UnprocessableEntityError,
          "A project can only have one type of item, either simple or groups"
      end
      item_types.first == Organization::ItemDto ? :item : :item_group
    end
  end
end
