import { Api } from "@/lib/openapi-fetch-query-client";
import { Card, CardContent } from "@/components/ui/card";
import { ClientSummaryCard } from "@/components/pages/companies/clients/shared/client-summary-card";
import { ProjectSummaryCard } from "@/components/pages/companies/projects/shared/project-summary-card";
import { ProjectInvoicingSummaryCard } from "@/components/pages/companies/invoices/private/project-invoicing-summary-card";
import { InvoiceContent } from "./private/invoice-content";
import { InvoiceActions } from "./private/invoice-actions";

const InvoiceShowContent = ({
  routeParams: { companyId, projectId, invoiceId },
}: {
  routeParams: {
    companyId: number;
    projectId: number;
    invoiceId: number;
  };
}) => {
  const { data: invoiceData } = Api.useQuery(
    "get",
    "/api/v1/organization/projects/{project_id}/invoices/{id}",
    {
      params: {
        path: { project_id: projectId, id: invoiceId },
      },
    },
    { select: ({ result }) => result }
  );

  const isInvoiceLoaded = invoiceData != undefined;

  const { data: projectData } = Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/projects/{id}",
    { params: { path: { company_id: companyId, id: projectId } } }
  );

  const isProjectDataLoaded = projectData != undefined;

  if (!isInvoiceLoaded || !isProjectDataLoaded) {
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
          projectId: projectId,
        }
      : {
          name: "toto",
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
          projectId={projectId}
          invoiceId={invoiceId}
        />
      </div>
      <div className="md:col-span-2">
        <Card>
          <CardContent className="mt-6 space-y-6">
            <ProjectInvoicingSummaryCard
              companyId={companyId}
              projectId={projectId}
              invoiceId={invoiceId}
            />
            <InvoiceContent
              companyId={companyId}
              invoiceId={invoiceId}
              projectId={projectId}
            />
          </CardContent>
        </Card>
      </div>
    </div>
  );
};

export { InvoiceShowContent };
