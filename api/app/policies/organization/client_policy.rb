module Organization
  class ClientPolicy < ApplicationPolicy
    class Scope < ApplicationPolicy::Scope
      def resolve
        scope.joins({ company: :members }).where("organization_members.user_id = ?", user.id)
      end
    end
  end
end
