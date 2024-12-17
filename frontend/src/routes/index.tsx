import { createFileRoute, Navigate } from "@tanstack/react-router";
import { useAuth } from "../hooks/use_auth";
import { Button } from "@/components/ui/button";
import { Layout } from "@/components/layout/layout";
import { getCompaniesQueryOptions } from "@/queries/organization/companies/getCompaniesQueryOptions";

export const Route = createFileRoute("/")({
  loader: ({ context: { queryClient } }) =>
    queryClient.ensureQueryData(getCompaniesQueryOptions),
  component: Index,
});

function Index() {
  const { logout } = useAuth();
  const data = Route.useLoaderData();

  const companyId = data[0]?.id;

  return companyId ? (
    <Navigate
      to="/organization/companies/$companyId/clients"
      params={{ companyId: companyId.toString() }}
    />
  ) : (
    <Layout companyId={companyId.toString()}>
      <div>
        <h1 className="text-sky-700">Hello from Home!</h1>
        <Button
          onClick={() => {
            logout();
          }}
        >
          Logout
        </Button>
      </div>
    </Layout>
  );
}
