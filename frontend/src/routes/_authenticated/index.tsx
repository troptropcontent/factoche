import { getCompaniesQueryOptions } from "@/queries/organization/companies/getCompaniesQueryOptions";
import { createFileRoute, Navigate, redirect } from "@tanstack/react-router";

export const Route = createFileRoute("/_authenticated/")({
  component: Index,
  loader: async ({ context: { queryClient } }) => {
    try {
      return await queryClient.ensureQueryData(getCompaniesQueryOptions());
    } catch {
      throw redirect({
        to: "/auth/login",
        search: { redirect: location.pathname },
      });
    }
  },
});

function Index() {
  const { data: companies } = Route.useLoaderData();
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
