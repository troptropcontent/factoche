import { LoadingButton } from "@/components/ui/button";
import { toast } from "@/hooks/use-toast";
import { Api } from "@/lib/openapi-fetch-query-client";
import { useNavigate } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";
import { InvoiceExtended } from "../shared/types";
import { FinancialTransactionPdfDownloadButton } from "../../financial_transactions/shared/financial-transaction-pdf-download-button";

const CancelButton = ({
  invoiceId,
  companyId,
}: {
  invoiceId: number;
  companyId: string;
}) => {
  const { t } = useTranslation();
  const { mutateAsync: cancelInvoiceMutation } = Api.useMutation(
    "post",
    "/api/v1/organization/invoices/{id}/cancel"
  );
  const navigate = useNavigate();

  const cancelInvoice = async () => {
    const onSuccess = () => {
      toast({
        title: t(
          "pages.companies.projects.invoices.completion_snapshot.show.actions.cancel_success_toast_title"
        ),
        description: t(
          "pages.companies.projects.invoices.completion_snapshot.show.actions.cancel_success_toast_description"
        ),
      });
      navigate({
        to: "/companies/$companyId/invoices/$invoiceId",
        params: {
          companyId: companyId.toString(),
          invoiceId: invoiceId.toString(),
        },
      });
    };

    const onError = () => {
      toast({
        variant: "destructive",
        title: t("common.toast.error_title"),
        description: t("common.toast.error_description"),
      });
    };

    await cancelInvoiceMutation(
      {
        params: { path: { id: invoiceId } },
      },
      {
        onSuccess,
        onError,
      }
    );
  };

  return (
    <LoadingButton variant="destructive" onClick={cancelInvoice}>
      {t(
        "pages.companies.projects.invoices.completion_snapshot.show.actions.cancel"
      )}
    </LoadingButton>
  );
};

const CancelledInvoiceActions = ({ invoice }: { invoice: InvoiceExtended }) => {
  const { t } = useTranslation();
  const creditNoteUrl = invoice?.credit_note?.pdf_url
    ? invoice.credit_note.pdf_url
    : undefined;

  const invoiceUrl = invoice.pdf_url;

  return (
    <>
      <FinancialTransactionPdfDownloadButton
        url={invoiceUrl}
        urlDefinedText={t(
          `pages.companies.projects.invoices.completion_snapshot.show.actions.download_invoice_pdf`
        )}
        urlUndefinedText={t(
          `pages.companies.projects.invoices.completion_snapshot.show.actions.invoice_pdf_unavailable`
        )}
      />

      <FinancialTransactionPdfDownloadButton
        url={creditNoteUrl}
        urlDefinedText={t(
          `pages.companies.projects.invoices.completion_snapshot.show.actions.download_credit_note_pdf`
        )}
        urlUndefinedText={t(
          `pages.companies.projects.invoices.completion_snapshot.show.actions.credit_note_pdf_unavailable`
        )}
      />
    </>
  );
};

const PostedInvoiceActions = ({
  invoice,
  companyId,
}: {
  invoice: InvoiceExtended;
  companyId: string;
}) => {
  const { t } = useTranslation();
  return (
    <>
      <FinancialTransactionPdfDownloadButton
        url={invoice.pdf_url}
        urlDefinedText={t(
          `pages.companies.projects.invoices.completion_snapshot.show.actions.download_invoice_pdf`
        )}
        urlUndefinedText={t(
          `pages.companies.projects.invoices.completion_snapshot.show.actions.invoice_pdf_unavailable`
        )}
      />
      <CancelButton invoiceId={invoice.id} companyId={companyId} />
    </>
  );
};

const FinancialTransactionShowInvoiceSpecificContentActions = ({
  invoice,
  companyId,
}: {
  invoice: InvoiceExtended;
  companyId: string;
}) => {
  return (
    <div className="flex flex-col gap-4">
      {(() => {
        switch (invoice.status) {
          case "posted":
            return (
              <PostedInvoiceActions invoice={invoice} companyId={companyId} />
            );
          case "cancelled":
            return <CancelledInvoiceActions invoice={invoice} />;
          default:
            throw new Error(`Unhandled invoice status: ${invoice.status}`);
        }
      })()}
    </div>
  );
};

export { FinancialTransactionShowInvoiceSpecificContentActions };
