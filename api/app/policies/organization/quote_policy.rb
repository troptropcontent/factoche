module Organization
  class QuotePolicy < ApplicationPolicy
    class Scope < ApplicationPolicy::Scope
      def resolve
        ProjectPolicy::Scope.base_query(scope, user).where(type: "Organization::Quote")
      end
    end
  end
end
