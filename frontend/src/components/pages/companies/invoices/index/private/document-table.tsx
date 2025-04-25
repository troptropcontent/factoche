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
import { useTranslation } from "react-i18next";
import { InvoiceCompact } from "../../shared/types";
import { Tab } from "../shared/types";
import { t } from "i18next";
import { ProjectVersionCompact } from "../../../project-versions/shared/types";
import { OrderCompact } from "../../../projects/shared/types";
import { DocumentTableRow } from "./document-table-row";
import { ProformaCompact } from "../../../proformas/shared/types";

const LoadedTableBody = ({
  companyId,
  documents,
  orderVersions,
  orders,
  tab,
}: {
  companyId: string;
  documents: InvoiceCompact[] | ProformaCompact[];
  orderVersions: ProjectVersionCompact[];
  orders: OrderCompact[];
  tab: Tab;
}) => {
  const { t } = useTranslation();

  return (
    <TableBody>
      {documents.length > 0 ? (
        documents.map((document) => (
          <DocumentTableRow
            tab={tab}
            companyId={companyId}
            document={document}
            orderVersions={orderVersions}
            orders={orders}
          />
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
  companyId,
  documentsData,
  tab,
}: {
  companyId: string;
  documentsData?: {
    documents: InvoiceCompact[] | ProformaCompact[];
    orders: OrderCompact[];
    orderVersions: ProjectVersionCompact[];
  };
  tab: Tab;
}) => {
  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead className="w-[150px]">
            {t(
              "pages.companies.projects.invoices.index.tabs.table.columns.number"
            )}
          </TableHead>
          <TableHead>
            {t(
              "pages.companies.projects.invoices.index.tabs.table.columns.client"
            )}
          </TableHead>
          <TableHead>
            {t(
              "pages.companies.projects.invoices.index.tabs.table.columns.order"
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
          <TableHead className="w-[100px]">
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
      {documentsData == undefined ? (
        <LoadingTableBody />
      ) : (
        <LoadedTableBody
          companyId={companyId}
          documents={documentsData.documents}
          orderVersions={documentsData.orderVersions}
          orders={documentsData.orders}
          tab={tab}
        />
      )}
    </Table>
  );
};

export { DocumentTable };
