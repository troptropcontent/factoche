import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { useProjectVersionTotalCents } from "../project-versions/shared/hooks";
import { useTranslation } from "react-i18next";
import {
  useCompletionSnapshotTotalCents,
  usePreviousCompletionSnapshotTotalCents,
} from "./shared/hooks";
import { Skeleton } from "@/components/ui/skeleton";

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
const CompletionSnapshotSummary = ({
  routeParams,
}: {
  routeParams: {
    companyId: number;
    projectId: number;
    projectVersionId: number;
    completionSnapshotId: number;
  };
}) => {
  const {
    projectVersionTotalCents,
    isLoading: isProjectVersionTotalCentsLoading,
  } = useProjectVersionTotalCents({
    companyId: routeParams.companyId,
    projectId: routeParams.projectId,
    projectVersionId: routeParams.projectVersionId,
  });

  const {
    completionSnapshotTotalCents,
    isLoading: isCompletionSnapshotTotalCentsLoading,
  } = useCompletionSnapshotTotalCents(routeParams.completionSnapshotId);

  const {
    previousCompletionSnapshotTotalCents,
    isLoading: isPreviousCompletionSnapshotTotalCentsLoading,
  } = usePreviousCompletionSnapshotTotalCents(routeParams.completionSnapshotId);

  const isTableDataLoaded =
    !isProjectVersionTotalCentsLoading &&
    !isCompletionSnapshotTotalCentsLoading &&
    !isPreviousCompletionSnapshotTotalCentsLoading;

  const { t } = useTranslation();

  return (
    <Card>
      <CardHeader>
        <CardTitle>
          {t("pages.companies.completion_snapshot.show.summary.title")}
        </CardTitle>
      </CardHeader>
      <CardContent>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>
                {t("pages.companies.completion_snapshot.show.summary.total")}
              </TableHead>
              <TableHead>
                {t(
                  "pages.companies.completion_snapshot.show.summary.previously_invoiced"
                )}
              </TableHead>
              <TableHead>
                {t(
                  "pages.companies.completion_snapshot.show.summary.new_completion_snapshot"
                )}
              </TableHead>
              <TableHead>
                {t(
                  "pages.companies.completion_snapshot.show.summary.new_invoiced"
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
                      amount: projectVersionTotalCents / 100,
                    })}
                  </TableCell>
                  <TableCell>
                    {t("common.number_in_currency", {
                      amount: previousCompletionSnapshotTotalCents / 100,
                    })}
                  </TableCell>
                  <TableCell>
                    {t("common.number_in_currency", {
                      amount: completionSnapshotTotalCents / 100,
                    })}
                  </TableCell>
                  <TableCell>
                    {t("common.number_in_currency", {
                      amount:
                        (completionSnapshotTotalCents -
                          previousCompletionSnapshotTotalCents) /
                        100,
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

export { CompletionSnapshotSummary };
