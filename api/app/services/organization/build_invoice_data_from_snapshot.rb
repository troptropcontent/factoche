# typed: true

module Organization
  class BuildInvoiceDataFromSnapshot
    class PaymentTerm < T::Struct
      const :days, Integer
      const :accepted_methods, T::Array[String]
    end

    class Address < T::Struct
      const :city, String
      const :street, String
      const :zip, String
    end

    class Seller < T::Struct
      const :name, String
      const :address, Address
      const :phone, String
      const :siret, String
      const :vat_number, String
      const :rcs_city, String
      const :rcs_number, String
    end

    class BillingAddress < T::Struct
      const :name, String
      const :address, Address
    end

    class DeliveryAddress < T::Struct
      const :name, String
      const :address, Address
    end

    class ProjectContext < T::Struct
      const :name, String
      const :version, Integer
      const :total_amount_cents, Integer
      const :previously_billed_amount, Numeric
    end

    class Item < T::Struct
      const :name, String
      const :description, T.nilable(String)
      const :item_group_id, T.nilable(Integer)
      const :quantity, Integer
      const :unit, String
      const :unit_price, BigDecimal
      const :previous_completion_percentage, BigDecimal
      const :new_completion_percentage, BigDecimal
    end

    class ItemGroup < T::Struct
      const :name, String
      const :description, T.nilable(String)
      const :id, Integer
    end

    class Result < T::Struct
      const :payment_term, PaymentTerm
      const :seller, Seller
      const :billing_address, BillingAddress
      const :delivery_address, DeliveryAddress
      const :project_context, ProjectContext
      const :items, T::Array[Item]
      const :item_groups, T::Array[ItemGroup]
    end

    class << self
      extend T::Sig

      sig { params(snapshot: Organization::CompletionSnapshot).returns(Result) }
      def call(snapshot)
        project_version, project, client, company, company_config = load_dependencies!(snapshot)

        Result.new(
          payment_term: payment_term(company_config),
          seller: seller(company),
          billing_address: billing_address(client),
          delivery_address: delivery_address(client),
          project_context: project_context(project, project_version),
          items: items(snapshot, project, project_version),
          item_groups: item_groups(project_version)
        )
      end

      private

      sig { params(snapshot: Organization::CompletionSnapshot).returns([ Organization::ProjectVersion, Organization::Project, Organization::Client, Organization::Company, Organization::CompanyConfig ]) }
      def load_dependencies!(snapshot)
        project_version = snapshot.project_version
        raise Error::UnprocessableEntityError.new("Project version is not defined") if project_version.nil?
        project = project_version.project
        raise Error::UnprocessableEntityError.new("Project is not defined") if project.nil?
        client = project.client
        raise Error::UnprocessableEntityError.new("Client is not defined") if client.nil?
        company = client.company
        raise Error::UnprocessableEntityError.new("Company is not defined") if company.nil?
        company_config = company.config
        raise Error::UnprocessableEntityError.new("CompanyConfig is not defined") if company_config.nil?

        [ project_version, project, client, company, company_config ]
      end

      sig { params(config: Organization::CompanyConfig).returns(PaymentTerm) }
      def payment_term(config)
        PaymentTerm.new(
          days: config.settings.dig("payment_term", "days"),
          accepted_methods: config.settings.dig("payment_term", "methods")
        )
      end

      sig { params(company: Organization::Company).returns(Seller) }
      def seller(company)
        Seller.new(
          name: company.name,
          phone: company.phone,
          siret: company.registration_number,
          rcs_city: company.rcs_city,
          rcs_number: company.rcs_number,
          vat_number: company.vat_number,
          address: Address.new(
            city: company.address_city,
            street: company.address_street,
            zip: company.address_zipcode
          )
        )
      end

      sig { params(client: Organization::Client).returns(BillingAddress) }
      def billing_address(client)
        BillingAddress.new(
          name: client.name,
          address: Address.new(
            city: client.address_city,
            street: client.address_street,
            zip: client.address_zipcode
          )
        )
      end

      sig { params(client: Organization::Client).returns(DeliveryAddress) }
      def delivery_address(client)
        DeliveryAddress.new(
          name: client.name,
          address: Address.new(
            city: client.address_city,
            street: client.address_street,
            zip: client.address_zipcode
          )
        )
      end

      sig { params(project: Organization::Project, project_version: Organization::ProjectVersion).returns(ProjectContext) }
      def project_context(project, project_version)
        ProjectContext.new(
          name: project.name,
          version: project_version.number,
          total_amount_cents: project_version.items.sum("quantity * unit_price_cents").to_i,
          previously_billed_amount: project.invoices.sum("total_amount_excl_tax") - project.credit_notes.sum("total_amount_excl_tax")
        )
      end

      sig { params(snapshot: Organization::CompletionSnapshot, project: Organization::Project, project_version: Organization::ProjectVersion).returns(T::Array[Item]) }
      def items(snapshot, project, project_version)
        previous_snapshot = project.completion_snapshots.where(created_at: ...snapshot.created_at).includes(:completion_snapshot_items).last
        snapshots_items = snapshot.completion_snapshot_items.index_by(&:item_id)

        project_version.items.map do |item|
          unit_price = BigDecimal(item.unit_price_cents) / 100
          previous_completion_snapshot_item = previous_snapshot ? previous_snapshot.completion_snapshot_items.find_by(item_id: item.id) : nil
          previous_completion_percentage = previous_completion_snapshot_item ? previous_completion_snapshot_item.completion_percentage : BigDecimal("0")
          new_completion_percentage = snapshots_items[item.id]&.completion_percentage || BigDecimal("0")

          Item.new(
            name: item.name,
            description: item.description,
            item_group_id: item.item_group_id,
            quantity: item.quantity,
            unit: item.unit,
            unit_price: unit_price,
            previous_completion_percentage: previous_completion_percentage,
            new_completion_percentage: new_completion_percentage
          )
        end
      end

      sig { params(project_version: Organization::ProjectVersion).returns(T::Array[ItemGroup]) }
      def item_groups(project_version)
        project_version.item_groups.map do |item_group|
          ItemGroup.new(
            name: item_group.name,
            description: item_group.description,
            id: item_group.id
          )
        end
      end
    end
  end
end
