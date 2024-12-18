import { createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/_authenticated/")({
  component: Index,
});

function Index() {
  return (
    <div>
      <h1 className="text-sky-700">Hello from Home!</h1>
    </div>
  );
}
