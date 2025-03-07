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
import { useTranslation } from "react-i18next";

import { NewCompletionSnapshotButton } from "./new-completion-snapshot-button";
import { useNavigate } from "@tanstack/react-router";
import { TrafficCone } from "lucide-react";
import { EmptyState } from "@/components/ui/empty-state";
import { CompletionSnapshotStatusBadge } from "../../completion-snapshot/shared/completion-snapshot-status-badge";

const CompletionSnapshotInvoicesSummery = ({
  companyId,
  projectId,
}: {
  companyId: number;
  projectId: number;
}) => {
  // TODO: Replace with invoice endpoint when available
  const {
    data: { results: invoices },
    isLoading,
  }: {
    data: {
      results: Array<{ id: number; created_at: string; status: string }>;
    };
    isLoading: boolean;
  } = {
    data: { results: [] },
    isLoading: false,
  };

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

  if (isLoading) {
    return;
  }

  return (
    <Card className="mt-6">
      <CardHeader>
        <CardTitle>
          {t(
            "pages.companies.projects.show.completion_snapshot_invoices_summary.title"
          )}
        </CardTitle>
      </CardHeader>
      <CardContent>
        {invoices.length > 0 && (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>
                  {t(
                    "pages.companies.projects.show.completion_snapshot_invoices_summary.columns.number"
                  )}
                </TableHead>
                <TableHead>
                  {t(
                    "pages.companies.projects.show.completion_snapshot_invoices_summary.columns.date"
                  )}
                </TableHead>
                <TableHead>
                  {t(
                    "pages.companies.projects.show.completion_snapshot_invoices_summary.columns.version"
                  )}
                </TableHead>
                <TableHead>
                  {t(
                    "pages.companies.projects.show.completion_snapshot_invoices_summary.columns.status"
                  )}
                </TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {invoices.map((invoice, index) => (
                <TableRow
                  key={index}
                  onClick={() => handleRowClick(invoice.id)}
                  className="cursor-pointer hover:bg-gray-100 transition-colors"
                  role="link"
                >
                  <TableCell>
                    {(index + 1).toString().padStart(2, "0")}
                  </TableCell>
                  <TableCell>
                    {t("common.date", {
                      date: Date.parse(invoice.created_at),
                    })}
                  </TableCell>
                  <TableCell>
                    <CompletionSnapshotStatusBadge status={invoice.status} />
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        )}
        {invoices.length === 0 && (
          <EmptyState
            icon={TrafficCone}
            title={t(
              "pages.companies.projects.show.completion_snapshot_invoices_summary.empty_state.title"
            )}
            description={t(
              "pages.companies.projects.show.completion_snapshot_invoices_summary.empty_state.description"
            )}
            actionLabel={t(
              "pages.companies.projects.show.completion_snapshot_invoices_summary.empty_state.action_label"
            )}
            onAction={() => {
              navigate({
                to: "/companies/$companyId/projects/$projectId/invoices/completion_snapshots/new",
                params: {
                  companyId: companyId.toString(),
                  projectId: projectId.toString(),
                },
              });
            }}
            className="flex-grow mb-4"
          />
        )}
      </CardContent>
      {invoices.length > 0 && (
        <CardFooter>
          <NewCompletionSnapshotButton {...{ companyId, projectId }} />
        </CardFooter>
      )}
    </Card>
  );
};

export { CompletionSnapshotInvoicesSummery };
