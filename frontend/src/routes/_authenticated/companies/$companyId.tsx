import { CompanyLayout } from "@/components/layout/company-layout";
import { getCompanyQueryOptions } from "@/queries/organization/companies/getCompanyQueryOptions";
import { createFileRoute, notFound, Outlet } from "@tanstack/react-router";

export const Route = createFileRoute("/_authenticated/companies/$companyId")({
  component: RouteComponent,
  loader: async ({ context: { queryClient }, params: { companyId } }) => {
    return await queryClient
      .ensureQueryData(getCompanyQueryOptions(companyId))
      .catch((error) => {
        if (error instanceof Error) {
          if (error.message.includes("404")) {
            throw notFound();
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
