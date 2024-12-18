import { CompanyLayout } from "@/components/layout/layout";
import { createFileRoute, Outlet } from "@tanstack/react-router";

export const Route = createFileRoute("/_authenticated/companies/$companyId")({
  component: RouteComponent,
});

function RouteComponent() {
  return (
    <CompanyLayout>
      <Outlet />
    </CompanyLayout>
  );
}
