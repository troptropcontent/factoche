import { Api } from "@/lib/openapi-fetch-query-client";
import { createFileRoute, Navigate, redirect } from "@tanstack/react-router";

export const Route = createFileRoute("/_authenticated/")({
  component: Index,
  loader: async ({ context: { queryClient } }) => {
    try {
      return await queryClient.ensureQueryData(
        Api.queryOptions("get", "/api/v1/organization/companies")
      );
    } catch {
      throw redirect({
        to: "/auth/login",
        search: { redirect: location.pathname },
      });
    }
  },
});

function Index() {
  const companies = Route.useLoaderData();
  const companyId = companies[0]?.id;
  if (companyId == undefined) {
    throw new Error("No company found. Please set up a company first.");
  }

  return (
    <Navigate
      to="/companies/$companyId"
      params={{ companyId: companyId.toString() }}
    />
  );
}
