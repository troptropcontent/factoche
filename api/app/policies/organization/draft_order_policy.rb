module Organization
  class DraftOrderPolicy < ApplicationPolicy
    class Scope < ApplicationPolicy::Scope
      def resolve
        ProjectPolicy::Scope.base_query(scope, user).where(type: "Organization::DraftOrder")
      end
    end
  end
end
