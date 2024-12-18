import { createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute(
  "/_authenticated/companies/$companyId/clients/"
)({
  component: RouteComponent,
});

function RouteComponent() {
  const { companyId } = Route.useParams();

  return <h1>Hello from the list of company {companyId} clients</h1>;
}
