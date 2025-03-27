import { Skeleton } from "@/components/ui/skeleton";
import {
  TableHead,
  TableHeader,
  TableRow,
  Table,
  TableBody,
  TableCell,
} from "@/components/ui/table";
import {} from "@/components/ui/table";
import { Link } from "@tanstack/react-router";
import { StatusBadge } from "../../private/status-badge";
import { Button } from "@/components/ui/button";
import { Download, Eye, Loader2 } from "lucide-react";
import { useTranslation } from "react-i18next";
import { InvoiceCompact } from "../../shared/types";
import { Tab } from "../shared/types";
import { t } from "i18next";

const LoadedTableBody = ({
  documents,
  tab,
}: {
  documents: InvoiceCompact[];
  tab: Tab;
}) => {
  const { t } = useTranslation();
  return (
    <TableBody>
      {documents.length > 0 ? (
        documents.map((document) => (
          <TableRow key={document.id}>
            <TableCell className="font-medium">{document.number}</TableCell>
            <TableCell>
              {t("common.date", {
                date: Date.parse(document.issue_date),
              })}
            </TableCell>
            <TableCell>
              {t("common.number_in_currency", {
                amount: document.total_amount,
              })}
            </TableCell>
            <TableCell>
              <StatusBadge status={document.status} />
            </TableCell>
            <TableCell className="text-right">
              <div className="flex justify-end gap-2">
                <Button variant="outline" size="sm" asChild>
                  <Link href={`/invoices/${document.id}`}>
                    <Eye />
                  </Link>
                </Button>
                <Button asChild variant="outline" size="sm">
                  {document.pdf_url ? (
                    <Link
                      to={`${import.meta.env.VITE_API_BASE_URL}${document.pdf_url}`}
                      target="_blank"
                    >
                      <Download />
                    </Link>
                  ) : (
                    <Link disabled>
                      <Loader2 className="animate-spin" />
                    </Link>
                  )}
                </Button>
              </div>
            </TableCell>
          </TableRow>
        ))
      ) : (
        <TableRow>
          <TableCell
            colSpan={7}
            className="text-center py-4 text-muted-foreground"
          >
            {t(
              `pages.companies.projects.invoices.index.tabs.${tab}.empty_state.title`
            )}
          </TableCell>
        </TableRow>
      )}
    </TableBody>
  );
};

const LoadingTableBody = () => {
  return (
    <TableBody>
      {Array.from({ length: 3 }).map((_, index) => (
        <TableRow key={index}>
          <TableCell className="font-medium">
            <Skeleton className="h-4 w-16" />
          </TableCell>
          <TableCell>
            <Skeleton className="h-4 w-32" />
          </TableCell>
          <TableCell>
            <Skeleton className="h-4 w-24" />
          </TableCell>
          <TableCell>
            <Skeleton className="h-4 w-24" />
          </TableCell>
          <TableCell className="text-right">
            <div className="flex justify-end gap-2">
              <Skeleton className="h-8 w-16" />
              <Skeleton className="h-8 w-16" />
            </div>
          </TableCell>
        </TableRow>
      ))}
    </TableBody>
  );
};

const DocumentTable = ({
  documents,
  tab,
}: {
  documents: InvoiceCompact[] | undefined;
  tab: Tab;
}) => {
  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>
            {t(
              "pages.companies.projects.invoices.index.tabs.table.columns.number"
            )}
          </TableHead>
          <TableHead>
            {t(
              "pages.companies.projects.invoices.index.tabs.table.columns.date"
            )}
          </TableHead>
          <TableHead>
            {t(
              "pages.companies.projects.invoices.index.tabs.table.columns.amount"
            )}
          </TableHead>
          <TableHead>
            {t(
              "pages.companies.projects.invoices.index.tabs.table.columns.status"
            )}
          </TableHead>
          <TableHead className="text-right">
            {t(
              "pages.companies.projects.invoices.index.tabs.table.columns.actions"
            )}
          </TableHead>
        </TableRow>
      </TableHeader>
      {documents == undefined ? (
        <LoadingTableBody />
      ) : (
        <LoadedTableBody documents={documents} tab={tab} />
      )}
    </Table>
  );
};

export { DocumentTable };
