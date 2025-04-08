class Api::V1::Organization::ClientsController < Api::V1::ApiV1Controller
  before_action(except: :show) { load_and_authorise_resource(name: :company, param_key: "company_id", class_name: "Organization::Company") }
  # POST /api/v1/organization/companies/:company_id/clients
  def create
    client = @company.clients.new(client_params)

    client.save!
    render json: Organization::ClientSerializer.render(client)
  end

  # GET /api/v1/organization/companies/:company_id/clients
  def index
    clients = @company.clients
    render json: Organization::ClientSerializer.render(clients)
  end

  # GET  /api/v1/organization/clients/:id
  def show
    client = policy_scope(Organization::Client).find(params[:id])

    render json: Organization::Clients::ShowDto.new({ result: client })
  end

  private

  def client_params
    params.require(:client).permit(:name, :email, :phone, :registration_number, :address_city, :address_street, :address_zipcode, :vat_number)
  end

  def load_company!
    @company = policy_scope(Organization::Company).find_by(id: params[:company_id])
    raise Error::NotFoundError unless @company
  end
end
