class Api::V1::Organization::CompaniesController < ApplicationController
  # GET /api/v1/organization/companies
  def index
    if company = current_user.companies.first
      render json: Organization::CompanySerializer.render(company)
    else
      render json: { error: "Company not found" }, status: :not_found
    end
  end
end
