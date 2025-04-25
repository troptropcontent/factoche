import { Layout } from "@/components/pages/companies/layout";
import { LoadingLayout } from "@/components/pages/companies/layout";
import { ProformaForm } from "@/components/pages/companies/proformas/form/proforma-form";
import { Api } from "@/lib/openapi-fetch-query-client";
import { createFileRoute } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";

export const Route = createFileRoute(
  "/_authenticated/companies/$companyId/orders/$orderId/proformas/new"
)({
  component: RouteComponent,
});

function RouteComponent() {
  const { t } = useTranslation();
  const { orderId, companyId } = Route.useParams();
  const { data: order } = Api.useQuery(
    "get",
    "/api/v1/organization/orders/{id}",
    { params: { path: { id: Number(orderId) } } },
    { select: ({ result }) => result }
  );

  return order == undefined ? (
    <LoadingLayout />
  ) : (
    <Layout.Root>
      <Layout.Header>
        <div className="flex flex-col">
          <h1 className="text-3xl font-bold">
            {t("pages.companies.proformas.new.title")}
          </h1>
        </div>
      </Layout.Header>
      <Layout.Content>
        <ProformaForm companyId={Number(companyId)} order={order} />
      </Layout.Content>
    </Layout.Root>
  );
}
