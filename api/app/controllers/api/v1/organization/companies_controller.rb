class Api::V1::Organization::CompaniesController < Api::V1::ApiV1Controller
  # GET /api/v1/organization/companies
  def index
    companies = policy_scope(Organization::Company)

    render json: Organization::CompanySerializer.render(companies)
  end

  # GET /api/v1/organization/companies/:id
  def show
    company = policy_scope(Organization::Company).find(params[:id])

    render json: Organization::Companies::ShowDto.new({ result: company }).to_json
  end

  # PUT /api/v1/organization/companies/:id
  def update
    company = policy_scope(Organization::Company).find(params[:id])

    result = ::Organization::Companies::Update.call(company.id, update_company_params.to_h)

    raise Error::UnprocessableEntityError, result.error if result.failure?

    render json: Organization::Companies::ShowDto.new({ result: result.data }).to_json
  end

  private

  def update_company_params
    params.require(:company).permit(
      :name,
      :registration_number,
      :email,
      :phone,
      :address_city,
      :address_street,
      :address_zipcode,
      :legal_form,
      :rcs_city,
      :rcs_number,
      :vat_number,
      :capital_amount,
      configs: %i[
        general_terms_and_condition
        default_vat_rate
        payment_term_days
        payment_term_accepted_methods
      ]
    )
  end
end
