import { createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/auth/users/$userId")({
  component: RouteComponent,
});

function RouteComponent() {
  const { userId } = Route.useParams();
  return <div>{`User ID: ${userId}`}</div>;
}
