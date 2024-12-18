import { isAuthed } from "@/lib/auth-service";
import { Outlet, createFileRoute, redirect } from "@tanstack/react-router";

import { Layout } from "@/components/layout/layout";
import { TanStackRouterDevtools } from "@tanstack/router-devtools";
import { getCompaniesQueryOptions } from "@/queries/organization/companies/getCompaniesQueryOptions";

export const Route = createFileRoute("/_authenticated")({
  beforeLoad: ({ location }) => {
    if (!isAuthed()) {
      throw redirect({
        to: "/auth/login",
        search: {
          redirect: location.href,
        },
      });
    }
  },
  loader: ({ context: { queryClient } }) =>
    queryClient.ensureQueryData(getCompaniesQueryOptions),
  component: AuthenticatedLayout,
});

function AuthenticatedLayout() {
  const companies = Route.useLoaderData();
  const companyId = companies[0].id;

  return (
    <Layout companyId={companyId.toString()}>
      <Outlet />
      <TanStackRouterDevtools />
    </Layout>
  );
}
