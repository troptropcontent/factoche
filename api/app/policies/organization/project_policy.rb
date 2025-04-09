module Organization
  class ProjectPolicy < ApplicationPolicy
    class Scope < ApplicationPolicy::Scope
      def self.base_query(scope, user)
        scope.joins({ client: { company: :members } }).where({ client: { company: { organization_members: { user_id: user.id } } } })
      end

      def resolve
        self.class.base_query(scope, user)
      end
    end
  end
end
