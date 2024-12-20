class Api::V1::Organization::ClientsController < Api::V1::ApiV1Controller
  # POST /api/v1/organization/companies/:company_id/clients
  def create
    company = policy_scope(Organization::Company).find_by(id: params[:company_id])
    raise Error::NotFoundError unless company

    client = company.clients.new(client_params)

    client.save!
    render json: Organization::ClientSerializer.render(client)
  end

  private

  def client_params
    params.require(:client).permit(:name, :email, :phone, :registration_number, :address_city, :address_street, :address_zipcode)
  end
end
