import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { TableBody, TableCell } from "@/components/ui/table";
import { TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Table } from "@/components/ui/table";
import { useTranslation } from "react-i18next";
import { computeCompletionSnapShotTotalCents } from "./completion-snapshot-form.utils";
import { computeProjectVersionTotalCents } from "../projects/shared/utils";

const ProjectInfo = ({
  projectData,
  lastCompletionSnapshotData,
}: {
  projectData: {
    name: string;
    description?: string | null;
    last_version: {
      id: number;
      number: number;
      created_at: string;
      item_groups: {
        description?: string | null;
        grouped_items: {
          id: number;
          quantity: number;
          unit_price_cents: number;
        }[];
      }[];
      ungrouped_items: {
        id: number;
        quantity: number;
        unit_price_cents: number;
      }[];
    };
  };
  lastCompletionSnapshotData?: {
    completion_snapshot_items: {
      item_id: number;
      completion_percentage: string;
    }[];
  };
}) => {
  const { t } = useTranslation();
  const lastCompletionSnapshotAmountCents = lastCompletionSnapshotData
    ? computeCompletionSnapShotTotalCents(
        lastCompletionSnapshotData.completion_snapshot_items,
        [
          ...projectData.last_version.ungrouped_items,
          ...projectData.last_version.item_groups,
        ]
      )
    : 0;

  const totalLastProjectVersionAmountCents = computeProjectVersionTotalCents(
    projectData.last_version
  );

  return (
    <Card>
      <CardHeader>
        <CardTitle>
          {t("pages.companies.completion_snapshot.form.project_info.title")}
        </CardTitle>
      </CardHeader>
      <CardContent>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>
                {t(
                  "pages.companies.completion_snapshot.form.project_info.name"
                )}
              </TableHead>
              <TableHead>
                {t(
                  "pages.companies.completion_snapshot.form.project_info.version"
                )}
              </TableHead>
              <TableHead>
                {t(
                  "pages.companies.completion_snapshot.form.project_info.total_project_amount"
                )}
              </TableHead>
              <TableHead>
                {t(
                  "pages.companies.completion_snapshot.form.project_info.previous_completion_percentage"
                )}
              </TableHead>
              <TableHead>
                {t(
                  "pages.companies.completion_snapshot.form.project_info.remaining_amount_to_invoice"
                )}
              </TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow>
              <TableCell
                className="max-w-[200px] text-wrap"
                title={projectData.name}
              >
                {projectData.name}
              </TableCell>
              <TableCell>
                {t("pages.companies.projects.show.version_label", {
                  number: projectData.last_version.number,
                  createdAt: Date.parse(projectData.last_version.created_at),
                })}
              </TableCell>
              <TableCell>
                {t("common.number_in_currency", {
                  amount: totalLastProjectVersionAmountCents / 100,
                })}
              </TableCell>
              <TableCell>
                {t("common.number_in_currency", {
                  amount: lastCompletionSnapshotAmountCents / 100,
                })}
              </TableCell>
              <TableCell>
                {t("common.number_in_currency", {
                  amount:
                    (totalLastProjectVersionAmountCents -
                      lastCompletionSnapshotAmountCents) /
                    100,
                })}
              </TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  );
};

export { ProjectInfo };
