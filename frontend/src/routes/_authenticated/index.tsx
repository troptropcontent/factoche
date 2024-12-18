import { getCompaniesQueryOptions } from "@/queries/organization/companies/getCompaniesQueryOptions";
import { createFileRoute, Navigate } from "@tanstack/react-router";

export const Route = createFileRoute("/_authenticated/")({
  component: Index,
  loader: ({ context: { queryClient } }) => {
    return queryClient.ensureQueryData(getCompaniesQueryOptions);
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
