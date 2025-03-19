import { ClientInfo } from "./client-info";
import { ProjectVersionComposition } from "./project-version-composition";
import { ProjectSummary } from "./project-summary";
import { InvoicesSummary } from "./invoices-summary";

const ProjectShowContent = ({
  companyId,
  orderId,
  client,
  initialVersionId,
}: {
  companyId: number;
  orderId: number;
  initialVersionId: number;
  lastVersionId: number;
  client: { name: string; phone: string; email: string };
}) => {
  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mt-6">
      <div className="md:col-span-1">
        <ProjectSummary routeParams={{ orderId }} />
        <ClientInfo client={client} />
        <InvoicesSummary companyId={companyId} orderId={orderId} />
      </div>
      <div className="md:col-span-2">
        <ProjectVersionComposition
          routeParams={{ companyId, orderId }}
          initialVersionId={initialVersionId}
        />
      </div>
    </div>
  );
};

export { ProjectShowContent };
