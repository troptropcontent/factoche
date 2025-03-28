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
import { CreditNoteCompact } from "../../shared/types";
import { t } from "i18next";
import { CreditNotesTableRow } from "./credit-notes-table-row";

const LoadedTableBody = ({
  creditNotes,
}: {
  creditNotes: CreditNoteCompact[];
}) => {
  const { t } = useTranslation();

  return (
    <TableBody>
      {creditNotes.length > 0 ? (
        creditNotes.map((creditNote) => (
          <CreditNotesTableRow creditNote={creditNote} />
        ))
      ) : (
        <TableRow>
          <TableCell
            colSpan={7}
            className="text-center py-4 text-muted-foreground"
          >
            {t(
              `pages.companies.projects.invoices.index.tabs.creditNotes.empty_state.title`
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

const CreditNotesTable = ({
  creditNotes,
}: {
  creditNotes: CreditNoteCompact[] | undefined;
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
              "pages.companies.projects.invoices.index.tabs.table.columns.invoice_number"
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
          <TableHead className="text-right">
            {t(
              "pages.companies.projects.invoices.index.tabs.table.columns.actions"
            )}
          </TableHead>
        </TableRow>
      </TableHeader>
      {creditNotes == undefined ? (
        <LoadingTableBody />
      ) : (
        <LoadedTableBody creditNotes={creditNotes} />
      )}
    </Table>
  );
};

export { CreditNotesTable };
