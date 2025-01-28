import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute(
  '/_authenticated/companies/$companyId/projects/$projectId/completion_snapshots/new',
)({
  component: RouteComponent,
})

function RouteComponent() {
  return (
    <div>
      Hello
      "/_authenticated/companies/$companyId/projects/$projectId/completion_snapshots/new"!
    </div>
  )
}
