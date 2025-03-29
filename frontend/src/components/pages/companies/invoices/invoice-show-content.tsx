import { Api } from "@/lib/openapi-fetch-query-client";
import { Card, CardContent } from "@/components/ui/card";
import { ClientSummaryCard } from "@/components/pages/companies/clients/shared/client-summary-card";
import { ProjectSummaryCard } from "@/components/pages/companies/projects/shared/project-summary-card";
import { ProjectInvoicingSummaryCard } from "@/components/pages/companies/invoices/private/project-invoicing-summary-card";
import { InvoiceContent } from "./private/invoice-content";
import { InvoiceActions } from "./private/invoice-actions";

const InvoiceShowContent = ({
  routeParams: { companyId, invoiceId },
}: {
  routeParams: {
    companyId: number;
    invoiceId: number;
  };
}) => {
  const { data: invoiceData } = Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/invoices/{id}",
    {
      params: {
        path: { company_id: companyId, id: invoiceId },
      },
    },
    { select: ({ result }) => result }
  );

  const isInvoiceLoaded = invoiceData != undefined;

  const { data: projectVersion } = Api.useQuery(
    "get",
    "/api/v1/organization/project_versions/{id}",
    {
      params: {
        path: { id: invoiceData?.holder_id ?? -1 }, // The -1 will never be sent as we set enabled: invoiceData !== undefined, this for typescript to be happy
      },
    },
    { select: ({ result }) => result, enabled: invoiceData !== undefined }
  );

  const isProjectVersionLoaded = projectVersion !== undefined;

  const { data: projectData } = Api.useQuery(
    "get",
    "/api/v1/organization/orders/{id}",
    { params: { path: { id: projectVersion?.project_id ?? -1 } } }, // The -1 will never be sent as we set enabled: projectVersion !== undefined, this for typescript to be happy
    { enabled: projectVersion !== undefined }
  );

  const isProjectDataLoaded = projectData != undefined;

  if (!isInvoiceLoaded || !isProjectDataLoaded || !isProjectVersionLoaded) {
    return null;
  }

  const clientSummaryCardProps =
    invoiceData.status === "draft"
      ? {
          clientId: projectData.result.client.id,
        }
      : {
          name: invoiceData.detail.client_name,
          phone: invoiceData.detail.client_phone,
          email: invoiceData.detail.client_email,
        };

  const projectSummaryProps =
    invoiceData.status === "draft"
      ? {
          companyId: companyId,
          orderId: projectData.result.id,
        }
      : {
          name: invoiceData.context.project_name,
          version_number: invoiceData.context.project_version_number,
          version_date: invoiceData.context.project_version_date,
        };

  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mt-6">
      <div className="md:col-span-1 space-y-6">
        <ProjectSummaryCard {...projectSummaryProps} />
        <ClientSummaryCard {...clientSummaryCardProps} />
        <InvoiceActions
          companyId={companyId}
          orderId={projectData.result.id}
          invoiceId={invoiceId}
        />
      </div>
      <div className="md:col-span-2">
        <Card>
          <CardContent className="mt-6 space-y-6">
            <ProjectInvoicingSummaryCard
              companyId={companyId}
              orderId={projectData.result.id}
              invoiceId={invoiceId}
            />
            <InvoiceContent
              invoiceId={invoiceId}
              orderId={projectData.result.id}
              companyId={companyId}
            />
          </CardContent>
        </Card>
      </div>
    </div>
  );
};

export { InvoiceShowContent };
