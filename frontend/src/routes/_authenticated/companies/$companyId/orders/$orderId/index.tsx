import { Layout } from "@/components/pages/companies/layout";
import { ProjectShowContentSpecificSection as OrderProjectShowContentSpecificSection } from "@/components/pages/companies/orders/project-show-content-specific-section";
import { ProjectShowContent } from "@/components/pages/companies/projects/show/project-show-content";
import { Skeleton } from "@/components/ui/skeleton";
import { Api } from "@/lib/openapi-fetch-query-client";
import { createFileRoute } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";

export const Route = createFileRoute(
  "/_authenticated/companies/$companyId/orders/$orderId/"
)({
  component: RouteComponent,
});

function RouteComponent() {
  const { companyId, orderId } = Route.useParams();
  const { data: order } = Api.useQuery(
    "get",
    "/api/v1/organization/orders/{id}",
    { params: { path: { id: Number(orderId) } } },
    { select: ({ result }) => result }
  );
  const { t } = useTranslation();
  return (
    <Layout.Root>
      <Layout.Header>
        {order == undefined ? (
          <Skeleton className="h-4 w-full" />
        ) : (
          <h1 className="text-3xl font-bold">
            {t("pages.companies.orders.show.title", {
              number: order.number,
            })}
          </h1>
        )}
      </Layout.Header>
      <Layout.Content>
        {order == undefined ? (
          <Skeleton className="h-full w-full" />
        ) : (
          <ProjectShowContent
            type="order"
            companyId={Number(companyId)}
            projectId={Number(orderId)}
            client={order.client}
            lastVersionId={order.last_version.id}
            initialVersionId={order.last_version.id}
          >
            <OrderProjectShowContentSpecificSection
              companyId={Number(companyId)}
              orderId={Number(orderId)}
            />
          </ProjectShowContent>
        )}
      </Layout.Content>
    </Layout.Root>
  );
}
