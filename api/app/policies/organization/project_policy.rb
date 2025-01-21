module Organization
  class ProjectPolicy < ApplicationPolicy
    class Scope < ApplicationPolicy::Scope
      def resolve
        scope.joins({ client: { company: :members } }).where({ client: { company: { organization_members: { user_id: user.id } } } })
      end
    end
  end
end
