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
import { Api } from "@/lib/openapi-fetch-query-client";

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
const CompletionSnapshotSummaryNew = ({
  routeParams,
}: {
  routeParams: {
    companyId: number;
    projectId: number;
    projectVersionId: number;
    completionSnapshotId: number;
  };
}) => {
  const { data: completionSnapshotData } = Api.useQuery(
    "get",
    "/api/v1/organization/completion_snapshots/{id}",
    {
      params: {
        path: { id: routeParams.completionSnapshotId },
      },
    }
  );

  const isTableDataLoaded = completionSnapshotData != undefined;

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
              <TableHead>
                {t(
                  "pages.companies.completion_snapshot.show.summary.new.total"
                )}
              </TableHead>
              <TableHead>
                {t(
                  "pages.companies.completion_snapshot.show.summary.new.previously_invoiced"
                )}
              </TableHead>
              <TableHead>
                {t(
                  "pages.companies.completion_snapshot.show.summary.new.new_completion_snapshot"
                )}
              </TableHead>
              <TableHead>
                {t(
                  "pages.companies.completion_snapshot.show.summary.new.new_invoiced"
                )}
              </TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow>
              {isTableDataLoaded ? (
                <>
                  <TableCell>
                    {t("common.number_in_currency", {
                      amount: parseFloat(
                        completionSnapshotData.result.invoice.payload
                          .project_context.total_amount
                      ),
                    })}
                  </TableCell>
                  <TableCell>
                    {t("common.number_in_currency", {
                      amount: parseFloat(
                        completionSnapshotData.result.invoice.payload
                          .project_context.previously_billed_amount
                      ),
                    })}
                  </TableCell>
                  <TableCell>
                    {t("common.number_in_currency", {
                      amount: parseFloat(
                        completionSnapshotData.result.invoice.payload
                          .transaction.total_excl_tax_amount
                      ),
                    })}
                  </TableCell>
                  <TableCell>
                    {t("common.number_in_currency", {
                      amount:
                        parseFloat(
                          completionSnapshotData.result.invoice.payload
                            .project_context.total_amount
                        ) -
                        parseFloat(
                          completionSnapshotData.result.invoice.payload
                            .project_context.previously_billed_amount
                        ) -
                        parseFloat(
                          completionSnapshotData.result.invoice.payload
                            .transaction.total_excl_tax_amount
                        ),
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

export { CompletionSnapshotSummaryNew };
