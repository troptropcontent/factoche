module Organization
  class CompletionSnapshotPolicy < ApplicationPolicy
    class Scope < ApplicationPolicy::Scope
      def resolve
        scope.joins({ project_version: { project: { client: { company: :members } } } }).where({ project_version: { project: { client: { company: { organization_members: { user_id: user.id } } } } } })
      end
    end
  end
end
