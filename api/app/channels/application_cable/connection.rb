module ApplicationCable
  class Connection < ActionCable::Connection::Base
    include JwtAuthenticatable
    identified_by :current_user, :current_company

    def connect
      self.current_user = authenticate_user_from_token
      self.current_company = authorise_company(self.current_user)
    end

    private

    def authenticate_user_from_token
      token = request.params["token"]
      reject_unauthorized_connection unless token.present?

      begin
        authenticate_token(token)
      rescue Error::ForbiddenError
        reject_unauthorized_connection
      end
    end

    def authorise_company(current_user)
      company_id = request.params["company_id"]
      reject_unauthorized_connection unless company_id.present?

      company = Organization::CompanyPolicy::Scope
                  .new(current_user, Organization::Company)
                  .resolve
                  .find_by(id: company_id)

      reject_unauthorized_connection unless company
      company
    end
  end
end
