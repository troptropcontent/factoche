import { Layout } from "@/components/pages/companies/layout";
import { createFileRoute } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";

import { Api } from "@/lib/openapi-fetch-query-client";
import { ProjectShowContent } from "@/components/pages/companies/projects/show/project-show-content";

export const Route = createFileRoute(
  "/_authenticated/companies/$companyId/quotes/$quoteId/"
)({
  component: RouteComponent,
  loader: ({ context: { queryClient }, params: { quoteId } }) =>
    queryClient.ensureQueryData(
      Api.queryOptions("get", "/api/v1/organization/quotes/{id}", {
        params: { path: { id: Number(quoteId) } },
      })
    ),
});

function RouteComponent() {
  const { companyId, quoteId } = Route.useParams();
  const { t } = useTranslation();
  const { result: quote } = Route.useLoaderData();

  return (
    <Layout.Root>
      <Layout.Header>
        <h1 className="text-3xl font-bold">
          {t("pages.companies.quotes.show.title", { number: quote.number })}
        </h1>
      </Layout.Header>
      <Layout.Content>
        <ProjectShowContent
          type="quote"
          companyId={Number(companyId)}
          projectId={Number(quoteId)}
          client={quote.client}
          lastVersionId={quote.last_version.id}
          initialVersionId={quote.last_version.id}
        />
      </Layout.Content>
    </Layout.Root>
  );
}
