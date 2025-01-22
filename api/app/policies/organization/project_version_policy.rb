module Organization
  class ProjectVersionPolicy < ApplicationPolicy
    class Scope < ApplicationPolicy::Scope
      def resolve
        scope.joins({ project: { client: { company: :members } } }).where({ project: { client: { company: { organization_members: { user_id: user.id } } } } })
      end
    end
  end
end
