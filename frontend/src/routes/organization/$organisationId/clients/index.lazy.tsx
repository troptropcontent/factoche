import { createLazyFileRoute } from "@tanstack/react-router";

export const Route = createLazyFileRoute(
  "/organization/$organisationId/clients/",
)({
  component: RouteComponent,
});

function RouteComponent() {
  return <div>Hello "/organization/$organisationId/clients/"!</div>;
}
