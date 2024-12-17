import { Layout } from '@/components/layout/layout'
import { createLazyFileRoute } from '@tanstack/react-router'

export const Route = createLazyFileRoute(
  '/organization/companies/$companyId/clients/',
)({
  component: RouteComponent,
})

function RouteComponent() {
  return <Layout>
    <h1>Hello from the list of all clients</h1>
  </Layout>
}
