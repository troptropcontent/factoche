import { CompanyLayout } from "@/components/layout/company-layout";
import { Api } from "@/lib/openapi-fetch-query-client";
import { getCompanyQueryOptions } from "@/queries/organization/companies/getCompanyQueryOptions";
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
      .catch((error) => {
        if (error instanceof Error) {
          if (error.message.includes("404")) {
            throw notFound();
          }
          if (error.message.includes("401")) {
            throw redirect({
              to: "/auth/login",
              search: { redirect: location.pathname },
            });
          }
        }
        throw new Error("Something went wrong");
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
