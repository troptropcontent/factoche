import { ClientInfo } from "./client-info";
import { ProjectVersionComposition } from "./project-version-composition";
import { ProjectSummary } from "./project-summary";
import { QuoteSpecificSection } from "./private/quote-specific-section";
import { ProjectTypeKey } from "../shared/types";
import { ReactNode } from "react";

const ProjectShowContent = ({
  companyId,
  projectId,
  client,
  initialVersionId,
  type,
  children,
}: {
  companyId: number;
  projectId: number;
  initialVersionId: number;
  lastVersionId: number;
  client: { name: string; phone: string; email: string };
  type: ProjectTypeKey;
  children?: ReactNode;
}) => {
  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mt-6">
      <div className="md:col-span-1 flex flex-col gap-6">
        <ProjectSummary routeParams={{ projectId }} type={type} />
        <ClientInfo client={client} />
        {type == "quote" && (
          <QuoteSpecificSection companyId={companyId} quoteId={projectId} />
        )}
        {children}
      </div>
      <div className="md:col-span-2">
        <ProjectVersionComposition
          routeParams={{ companyId, projectId }}
          initialVersionId={initialVersionId}
        />
      </div>
    </div>
  );
};

export { ProjectShowContent };
