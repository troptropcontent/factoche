import { TableCell, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Link } from "@tanstack/react-router";
import { Download, Loader2 } from "lucide-react";
import { CreditNoteCompact } from "../../shared/types";
import { useTranslation } from "react-i18next";

const CreditNotesTableRow = ({
  creditNote,
}: {
  creditNote: CreditNoteCompact;
}) => {
  const { t } = useTranslation();

  return (
    <TableRow key={creditNote.id}>
      <TableCell className="font-medium">{creditNote.number}</TableCell>
      <TableCell>{creditNote.invoice.number}</TableCell>
      <TableCell>
        {t("common.date", {
          date: Date.parse(creditNote.issue_date),
        })}
      </TableCell>
      <TableCell>
        {t("common.number_in_currency", {
          amount: creditNote.total_amount,
        })}
      </TableCell>
      <TableCell className="text-right">
        <div className="flex justify-end gap-2">
          <Button asChild variant="outline" size="sm">
            {creditNote.pdf_url ? (
              <Link
                to={`${import.meta.env.VITE_API_BASE_URL}${creditNote.pdf_url}`}
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
  );
};

export { CreditNotesTableRow };
