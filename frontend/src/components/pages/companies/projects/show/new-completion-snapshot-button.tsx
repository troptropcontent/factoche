import { PlusCircle } from "lucide-react";

import { Button } from "@/components/ui/button";
import { Link } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";
import { Api } from "@/lib/openapi-fetch-query-client";
import { t } from "i18next";

const ButtonContent = () => {
  const { t } = useTranslation();
  return (
    <>
      <PlusCircle className="h-4 w-4" />
      {t("pages.companies.projects.show.new_completion_snapshot")}
    </>
  );
};

const NewCompletionSnapshotButton = ({
  companyId,
  projectId,
}: {
  companyId: number;
  projectId: number;
}) => {
  const {
    data: { results: snapshots } = { results: [] },
    isLoading: isSnapShotsLoading,
  } = Api.useQuery("get", "/api/v1/organization/completion_snapshots", {
    params: {
      query: { filter: { company_id: companyId, project_id: projectId } },
    },
  });
  const isButtonDisabled =
    isSnapShotsLoading || snapshots.some(({ status }) => status === "draft");

  return (
    <div className="w-full">
      <Button
        disabled={isButtonDisabled}
        asChild={!isButtonDisabled}
        className="text-wrap w-full"
      >
        {isButtonDisabled ? (
          <ButtonContent />
        ) : (
          <Link
            to={`/companies/$companyId/projects/$projectId/completion_snapshots/new`}
            params={{
              companyId: companyId.toString(),
              projectId: projectId.toString(),
            }}
          >
            <ButtonContent />
          </Link>
        )}
      </Button>
      {isButtonDisabled && !isSnapShotsLoading && (
        <p className="text-xs text-muted-foreground mt-2 text-center">
          {t(
            "pages.companies.projects.show.completion_snapshots_summary.new_completion_snapshot_button.disabled_hint"
          )}
        </p>
      )}
    </div>
  );
};

export { NewCompletionSnapshotButton };
