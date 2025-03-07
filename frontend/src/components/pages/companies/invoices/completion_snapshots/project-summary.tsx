import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { TableBody, TableCell } from "@/components/ui/table";
import { TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Table } from "@/components/ui/table";
import { useTranslation } from "react-i18next";

const ProjectSummary = ({
  projectName,
  projectVersion,
  previouslyInvoicedAmount,
  projectTotalAmount,
}: {
  projectName: string;
  projectVersion: { number: number; created_at: string };
  previouslyInvoicedAmount: number;
  projectTotalAmount: number;
}) => {
  const { t } = useTranslation();

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
                title={projectName}
              >
                {projectName}
              </TableCell>
              <TableCell>
                {t("pages.companies.projects.show.version_label", {
                  number: projectVersion.number,
                  createdAt: Date.parse(projectVersion.created_at),
                })}
              </TableCell>
              <TableCell>
                {t("common.number_in_currency", {
                  amount: projectTotalAmount,
                })}
              </TableCell>
              <TableCell>
                {t("common.number_in_currency", {
                  amount: previouslyInvoicedAmount,
                })}
              </TableCell>
              <TableCell>
                {t("common.number_in_currency", {
                  amount: projectTotalAmount - previouslyInvoicedAmount,
                })}
              </TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  );
};

export { ProjectSummary };
