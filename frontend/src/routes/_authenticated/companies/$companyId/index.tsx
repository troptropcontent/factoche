import { createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/_authenticated/companies/$companyId/")({
  component: RouteComponent,
});

function RouteComponent() {
  const { companyId } = Route.useParams();
  return <h1>Dashboard of company {companyId}</h1>;
}
