import { CompletionSnapshotShow } from '@/components/pages/companies/completion-snapshot/completion-snapshot-show-content'
import { CompletionSnapshotStatusBadge } from '@/components/pages/companies/completion-snapshot/shared/completion-snapshot-status-badge'
import { Layout } from '@/components/pages/companies/layout'
import { Api } from '@/lib/openapi-fetch-query-client'
import { createFileRoute } from '@tanstack/react-router'
import { useTranslation } from 'react-i18next'

export const Route = createFileRoute(
  '/_authenticated/companies/$companyId/projects/$projectId/completion_snapshots/$completionSnapshotId/',
)({
  component: RouteComponent,
  loader: ({ context: { queryClient }, params: { completionSnapshotId } }) =>
    queryClient.ensureQueryData(
      Api.queryOptions(
        'get',
        '/api/v1/organization/completion_snapshots/{id}',
        { params: { path: { id: Number(completionSnapshotId) } } },
      ),
    ),
})

function RouteComponent() {
  const { result: completionSnapshot } = Route.useLoaderData()
  const routeParams = Route.useParams()

  const { t } = useTranslation()
  return (
    <Layout.Root>
      <Layout.Header>
        <div className="flex flex-grow items-center">
          <h1 className="text-3xl font-bold mr-auto">
            {t('pages.companies.completion_snapshot.show.title')}
          </h1>
          <CompletionSnapshotStatusBadge status={completionSnapshot.status} />
        </div>
      </Layout.Header>
      <Layout.Content>
        <CompletionSnapshotShow
          routeParams={{
            companyId: Number(routeParams.companyId),
            projectId: Number(routeParams.projectId),
            completionSnapshotId: completionSnapshot.id,
          }}
        />
      </Layout.Content>
    </Layout.Root>
  )
}
