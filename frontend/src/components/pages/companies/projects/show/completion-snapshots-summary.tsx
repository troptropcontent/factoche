import {
  Card,
  CardContent,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Api } from "@/lib/openapi-fetch-query-client";
import { useTranslation } from "react-i18next";
import { CompletionSnapshotStatusBadge } from "./completion-snapshot-status-badge";
import { NewCompletionSnapshotButton } from "./new-completion-snapshot-button";
import { useNavigate } from "@tanstack/react-router";
import { TrafficCone } from "lucide-react";
import { EmptyState } from "@/components/ui/empty-state";

const CompletionSnapshotsSummery = ({
  companyId,
  projectId,
}: {
  companyId: number;
  projectId: number;
}) => {
  const { data: { results: snapshots } = { results: [] } } = Api.useQuery(
    "get",
    "/api/v1/organization/completion_snapshots",
    {
      params: {
        query: { filter: { company_id: companyId, project_id: projectId } },
      },
    }
  );

  const navigate = useNavigate();

  const handleRowClick = (snapshotId: number) =>
    navigate({
      to: "/companies/$companyId/projects/$projectId/completion_snapshots/$completionSnapshotId",
      params: {
        companyId: companyId.toString(),
        completionSnapshotId: snapshotId.toString(),
        projectId: projectId.toString(),
      },
    });

  const { t } = useTranslation();

  return (
    <Card className="mt-6">
      <CardHeader>
        <CardTitle>
          {t(
            "pages.companies.projects.show.completion_snapshots_summary.title"
          )}
        </CardTitle>
      </CardHeader>
      <CardContent>
        {snapshots.length > 0 && (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>
                  {t(
                    "pages.companies.projects.show.completion_snapshots_summary.columns.number"
                  )}
                </TableHead>
                <TableHead>
                  {t(
                    "pages.companies.projects.show.completion_snapshots_summary.columns.date"
                  )}
                </TableHead>
                <TableHead>
                  {t(
                    "pages.companies.projects.show.completion_snapshots_summary.columns.version"
                  )}
                </TableHead>
                <TableHead>
                  {t(
                    "pages.companies.projects.show.completion_snapshots_summary.columns.status"
                  )}
                </TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {snapshots.map((snapshot, index) => (
                <TableRow
                  key={index}
                  onClick={() => handleRowClick(snapshot.id)}
                  className="cursor-pointer hover:bg-gray-100 transition-colors"
                  role="link"
                >
                  <TableCell>
                    {(index + 1).toString().padStart(2, "0")}
                  </TableCell>
                  <TableCell>
                    {t("common.date", {
                      date: Date.parse(snapshot.created_at),
                    })}
                  </TableCell>
                  <TableCell>{snapshot.project_version.number}</TableCell>
                  <TableCell>
                    <CompletionSnapshotStatusBadge status={snapshot.status} />
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        )}
        {snapshots.length === 0 && (
          <EmptyState
            icon={TrafficCone}
            title={t(
              "pages.companies.projects.show.completion_snapshots_summary.empty_state.title"
            )}
            description={t(
              "pages.companies.projects.show.completion_snapshots_summary.empty_state.description"
            )}
            actionLabel={t(
              "pages.companies.projects.show.completion_snapshots_summary.empty_state.action_label"
            )}
            onAction={() => {}}
            className="flex-grow mb-4"
          />
        )}
      </CardContent>
      {snapshots.length > 0 && (
        <CardFooter>
          <NewCompletionSnapshotButton {...{ companyId, projectId }} />
        </CardFooter>
      )}
    </Card>
  );
};

export { CompletionSnapshotsSummery };
