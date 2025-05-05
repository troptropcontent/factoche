import { Layout, LoadingLayout } from "@/components/pages/companies/layout";
import { ProformaForm } from "@/components/pages/companies/proformas/form/proforma-form";
import { Api } from "@/lib/openapi-fetch-query-client";
import { createFileRoute } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";

export const Route = createFileRoute(
  "/_authenticated/companies/$companyId/proformas/$proformaId/edit"
)({
  component: RouteComponent,
});

function RouteComponent() {
  const { companyId, proformaId } = Route.useParams();
  const { t } = useTranslation();

  const { data: proforma } = Api.useQuery(
    "get",
    "/api/v1/organization/proformas/{id}",
    { params: { path: { id: Number(proformaId) } } },
    { select: ({ result }) => result }
  );

  const { data: orderVersion } = Api.useQuery(
    "get",
    "/api/v1/organization/project_versions/{id}",
    { params: { path: { id: proforma?.holder_id || -1 } } },
    { select: ({ result }) => result, enabled: proforma !== undefined }
  );

  const { data: order } = Api.useQuery(
    "get",
    "/api/v1/organization/orders/{id}",
    { params: { path: { id: orderVersion?.project_id || -1 } } },
    { select: ({ result }) => result, enabled: orderVersion !== undefined }
  );

  const isDataLoaded = proforma !== undefined && order !== undefined;

  return !isDataLoaded ? (
    <LoadingLayout />
  ) : (
    <Layout.Root>
      <Layout.Header>
        <div className="flex flex-col">
          <h1 className="text-3xl font-bold">
            {t(
              "pages.companies.projects.invoices.completion_snapshot.new.title"
            )}
          </h1>
        </div>
      </Layout.Header>
      <Layout.Content>
        <ProformaForm
          companyId={Number(companyId)}
          order={order}
          proformaId={proforma.id}
        />
      </Layout.Content>
    </Layout.Root>
  );
}
