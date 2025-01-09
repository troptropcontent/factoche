import { Layout } from "@/components/pages/companies/layout";
import { Button } from "@/components/ui/button";
import { createFileRoute, Link } from "@tanstack/react-router";
import { PlusCircle } from "lucide-react";

import { useTranslation } from "react-i18next";

export const Route = createFileRoute(
  "/_authenticated/companies/$companyId/projects/"
)({
  component: RouteComponent,
});

function RouteComponent() {
  const { companyId } = Route.useParams();
  const { t } = useTranslation();

  return (
    <Layout.Root>
      <Layout.Header>
        <div className="flex flex-grow justify-between items-center">
          <h1 className="text-3xl font-bold">
            {t("pages.companies.projects.index.title")}
          </h1>
          <Button asChild>
            <Link
              to={`/companies/$companyId/projects/new`}
              params={{ companyId }}
            >
              <PlusCircle className="mr-2 h-4 w-4" />
              {t("pages.companies.projects.index.add_project")}
            </Link>
          </Button>
        </div>
      </Layout.Header>
      <Layout.Content>
        <div className="container mx-auto">
          {/* TODO: Implement index content */}
        </div>
      </Layout.Content>
    </Layout.Root>
  );
}
