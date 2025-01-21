import { Layout } from "@/components/pages/companies/layout";
import { createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute(
  "/_authenticated/companies/$companyId/projects/$projectId/"
)({
  component: RouteComponent,
});

function RouteComponent() {
  return (
    <Layout.Root>
      <Layout.Header>
        <div className="flex flex-grow justify-between items-center">
          <h1 className="text-3xl font-bold">Project Show Title</h1>
        </div>
      </Layout.Header>
      <Layout.Content>Project Show Content</Layout.Content>
    </Layout.Root>
  );
}
