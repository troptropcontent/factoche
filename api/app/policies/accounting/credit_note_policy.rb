module Accounting
  class CreditNotePolicy < ApplicationPolicy
    class Scope < ApplicationPolicy::Scope
      def resolve
        scope.joins("JOIN organization_companies ON accounting_financial_transactions.company_id = organization_companies.id JOIN organization_members ON organization_members.company_id = organization_companies.id").where("organization_members.user_id = ?", user.id)
      end
    end
  end
end
