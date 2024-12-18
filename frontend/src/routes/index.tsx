import { createFileRoute } from "@tanstack/react-router";

import { getCompaniesQueryOptions } from "@/queries/organization/companies/getCompaniesQueryOptions";

export const Route = createFileRoute("/")({
  loader: ({ context: { queryClient } }) =>
    queryClient.ensureQueryData(getCompaniesQueryOptions),
  component: Index,
});

function Index() {
  return (
    <div>
      <h1 className="text-sky-700">Hello from Home!</h1>
    </div>
  );
}
