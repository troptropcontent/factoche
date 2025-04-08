module Organization
  class OrderPolicy < ApplicationPolicy
    class Scope < ApplicationPolicy::Scope
      def resolve
        ProjectPolicy::Scope.base_query(scope, user).where(type: "Organization::Order")
      end
    end
  end
end
