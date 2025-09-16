class Api::V1::Organization::BankDetailsController < Api::V1::ApiV1Controller
  before_action { load_and_authorise_resource(name: :company, param_key: "company_id", class_name: "Organization::Company") }

  # GET /api/v1/organization/companies/:company_id/bank_details
  def index
    bank_details = policy_scope(Organization::BankDetail).where(company: @company)

    render json: Organization::BankDetails::ShowDto.new({ results: bank_details }).to_json
  end
end
