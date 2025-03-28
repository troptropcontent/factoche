import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { useTranslation } from "react-i18next";
import { Skeleton } from "@/components/ui/skeleton";

import { useInvoicingSummaryCardData } from "./hooks";

const LoadingTable = () => (
  <>
    <TableCell>
      <Skeleton className="w-full h-4" />
    </TableCell>
    <TableCell>
      <Skeleton className="w-full h-4" />
    </TableCell>
    <TableCell>
      <Skeleton className="w-full h-4" />
    </TableCell>
    <TableCell>
      <Skeleton className="w-full h-4" />
    </TableCell>
  </>
);
const ProjectInvoicingSummaryCard = ({
  companyId,
  orderId,
  invoiceId,
}: {
  companyId: number;
  orderId: number;
  invoiceId: number;
}) => {
  const { invoicingSummaryCardData } = useInvoicingSummaryCardData({
    companyId,
    orderId,
    invoiceId,
  });

  const isTableDataLoaded = invoicingSummaryCardData != undefined;

  const { t } = useTranslation();

  return (
    <Card>
      <CardHeader>
        <CardTitle>
          {t("pages.companies.completion_snapshot.show.summary.new.title")}
        </CardTitle>
      </CardHeader>
      <CardContent>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead className="w-[15%] align-top">
                {t(
                  "pages.companies.projects.invoices.completion_snapshot.show.content.withGroups.columns.total"
                )}
              </TableHead>
              <TableHead className="w-[15%] text-center">
                {t(
                  "pages.companies.projects.invoices.completion_snapshot.show.content.withGroups.columns.previously_invoiced"
                )}
                <br />
                (a)
              </TableHead>
              <TableHead className="w-[20%] text-center">
                {t(
                  "pages.companies.projects.invoices.completion_snapshot.show.content.withGroups.columns.new_snapshot"
                )}
                <br />
                (b)
              </TableHead>
              <TableHead className="w-[20%] text-center">
                {t(
                  "pages.companies.projects.invoices.completion_snapshot.show.content.withGroups.columns.new_invoice"
                )}
                <br />
                (b - a)
              </TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow>
              {isTableDataLoaded ? (
                <>
                  <TableCell className="align-top">
                    {t("common.number_in_currency", {
                      amount: invoicingSummaryCardData.projectTotalAmount,
                    })}
                  </TableCell>
                  <TableCell className="text-center">
                    <div>
                      <p>
                        {t("common.number_in_currency", {
                          amount:
                            invoicingSummaryCardData.previouslyInvoicedAmount,
                        })}
                      </p>
                      <p className="text-xs text-muted-foreground">
                        {t("common.number_in_percentage", {
                          amount:
                            (invoicingSummaryCardData.previouslyInvoicedAmount /
                              invoicingSummaryCardData.projectTotalAmount) *
                            100,
                        })}
                      </p>
                    </div>
                  </TableCell>
                  <TableCell className="text-center">
                    <div>
                      <p>
                        {t("common.number_in_currency", {
                          amount: invoicingSummaryCardData.newSnapshotAmount,
                        })}
                      </p>
                      <p className="text-xs text-muted-foreground">
                        {t("common.number_in_percentage", {
                          amount:
                            (invoicingSummaryCardData.newSnapshotAmount /
                              invoicingSummaryCardData.projectTotalAmount) *
                            100,
                        })}
                      </p>
                    </div>
                  </TableCell>
                  <TableCell className="text-center align-top">
                    {t("common.number_in_currency", {
                      amount: invoicingSummaryCardData.invoiceTotalAmount,
                    })}
                  </TableCell>
                </>
              ) : (
                <LoadingTable />
              )}
            </TableRow>
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  );
};

export { ProjectInvoicingSummaryCard };
