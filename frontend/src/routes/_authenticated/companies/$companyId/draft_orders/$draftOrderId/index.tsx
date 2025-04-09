import { ProjectShowContentSpecificSection as DraftOrderProjectShowContentSpecificSection } from "@/components/pages/companies/draft_orders/project_show_content_specific_section";
import { Layout } from "@/components/pages/companies/layout";
import { ProjectShowContent } from "@/components/pages/companies/projects/show/project-show-content";
import { Skeleton } from "@/components/ui/skeleton";
import { Api } from "@/lib/openapi-fetch-query-client";
import { createFileRoute } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";

export const Route = createFileRoute(
  "/_authenticated/companies/$companyId/draft_orders/$draftOrderId/"
)({
  component: RouteComponent,
});

function RouteComponent() {
  const { companyId, draftOrderId } = Route.useParams();
  const { data: draftOrder } = Api.useQuery(
    "get",
    "/api/v1/organization/draft_orders/{id}",
    { params: { path: { id: Number(draftOrderId) } } },
    { select: ({ result }) => result }
  );
  const { t } = useTranslation();
  const isLoading = draftOrder === undefined;
  return (
    <Layout.Root>
      <Layout.Header>
        {isLoading ? (
          <Skeleton className="h-4 w-full" />
        ) : (
          <h1 className="text-3xl font-bold">
            {t("pages.companies.draft_orders.show.title", {
              number: draftOrder?.number,
            })}
          </h1>
        )}
      </Layout.Header>
      <Layout.Content>
        {isLoading ? (
          <Skeleton className="h-full w-full" />
        ) : (
          <ProjectShowContent
            type="draft_order"
            companyId={Number(companyId)}
            projectId={Number(draftOrderId)}
            client={draftOrder.client}
            lastVersionId={draftOrder.last_version.id}
            initialVersionId={draftOrder.last_version.id}
          >
            <DraftOrderProjectShowContentSpecificSection
              companyId={Number(companyId)}
              draftOrderId={draftOrder.id}
            />
          </ProjectShowContent>
        )}
      </Layout.Content>
    </Layout.Root>
  );
}
