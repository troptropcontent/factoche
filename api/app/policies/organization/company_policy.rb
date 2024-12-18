module Organization
  class CompanyPolicy < ApplicationPolicy
    class Scope < ApplicationPolicy::Scope
      def resolve
        scope.joins(:members).where({ members: { user_id: user.id } })
      end
    end
  end
end
