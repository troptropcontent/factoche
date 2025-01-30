import { CompanyLayout } from "@/components/layout/company-layout";
import { Api } from "@/lib/openapi-fetch-query-client";

import {
  createFileRoute,
  notFound,
  Outlet,
  redirect,
} from "@tanstack/react-router";

export const Route = createFileRoute("/_authenticated/companies/$companyId")({
  component: RouteComponent,
  loader: async ({ context: { queryClient }, params: { companyId } }) => {
    return await queryClient
      .ensureQueryData(
        Api.queryOptions("get", "/api/v1/organization/companies/{id}", {
          params: { path: { id: Number(companyId) } },
        })
      )
      .catch(({ error: { code } }) => {
        if (code === 404) {
          throw notFound();
        }
        if (code === 403) {
          throw redirect({
            to: "/auth/login",
            search: { redirect: location.pathname },
          });
        }

        throw new Error("Something went super wrong");
      });
  },
});

function RouteComponent() {
  return (
    <CompanyLayout>
      <Outlet />
    </CompanyLayout>
  );
}
