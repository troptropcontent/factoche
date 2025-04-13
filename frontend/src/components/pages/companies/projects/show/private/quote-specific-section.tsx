import { Button } from "@/components/ui/button";
import { useChannelSubscription } from "@/hooks/use-channel-subscription";
import { useToast } from "@/hooks/use-toast";
import { Api } from "@/lib/openapi-fetch-query-client";
import { Link, useNavigate } from "@tanstack/react-router";
import { Download, Loader2, Pen } from "lucide-react";
import { useTranslation } from "react-i18next";

const QuoteSpecificSection = ({
  quoteId,
  companyId,
}: {
  quoteId: number;
  companyId: number;
}) => {
  const { toast } = useToast();
  const navigate = useNavigate();
  const { t } = useTranslation();
  const { data: quote, refetch } = Api.useQuery(
    "get",
    "/api/v1/organization/quotes/{id}",
    { params: { path: { id: quoteId } } },
    { select: ({ result }) => result }
  );

  const { mutate: convertToDraftOrderMutation } = Api.useMutation(
    "post",
    "/api/v1/organization/quotes/{id}/convert_to_draft_order"
  );

  useChannelSubscription({
    channelName: `NotificationsChannel`,
    onReceive: (data) => {
      if (
        data.type == "PDF_GENERATED" &&
        data.data.record_id === quote?.last_version.id
      ) {
        refetch();
      }
    },
  });

  if (quote == undefined) {
    return null;
  }

  const documentUrl = quote.last_version.pdf_url;

  const draftOrder = quote.draft_orders[0];
  const convertToDraftOrder = () => {
    const onSuccess = ({
      result: { id: draftOrderId },
    }: {
      result: { id: number };
    }) => {
      toast({
        title: t(
          "pages.companies.quotes.show.actions.convert_to_order_success_toast_title"
        ),
        description: t(
          "pages.companies.quotes.show.actions.convert_to_order_success_toast_description"
        ),
        variant: "success",
      });
      navigate({
        to: "/companies/$companyId/draft_orders/$draftOrderId",
        params: {
          companyId: companyId.toString(),
          draftOrderId: draftOrderId.toString(),
        },
      });
    };

    const onError = () => {
      toast({
        variant: "destructive",
        title: t(
          "pages.companies.quotes.show.actions.convert_to_order_error_toast_title"
        ),
        description: t(
          "pages.companies.quotes.show.actions.convert_to_order_error_toast_description"
        ),
      });
    };
    convertToDraftOrderMutation(
      { params: { path: { id: quoteId } } },
      { onSuccess, onError }
    );
  };

  return (
    <>
      <Button asChild variant="outline">
        {documentUrl ? (
          <Link to={`${import.meta.env.VITE_API_BASE_URL}${documentUrl}`}>
            <Download className="mr-2 h-4 w-4" />
            {t("pages.companies.quotes.show.actions.download_quote_pdf")}
          </Link>
        ) : (
          <Link disabled>
            <Loader2 className="mr-2 h-4 w-4 animate-spin" />
            {t("pages.companies.quotes.show.actions.quote_pdf_unavailable")}
          </Link>
        )}
      </Button>
      {draftOrder ? (
        <Button variant="default">
          <Link
            to="/companies/$companyId/draft_orders/$draftOrderId"
            params={{
              companyId: companyId.toString(),
              draftOrderId: draftOrder.id.toString(),
            }}
          >
            {t("pages.companies.quotes.show.actions.go_order")}
          </Link>
        </Button>
      ) : (
        <>
          <Button variant="default" onClick={convertToDraftOrder}>
            {t("pages.companies.quotes.show.actions.convert_to_order")}
          </Button>
          <Button asChild variant="outline">
            <Link
              to={"/companies/$companyId/quotes/$quoteId/update"}
              params={{
                companyId: companyId.toString(),
                quoteId: quoteId.toString(),
              }}
            >
              <Pen className="mr-2 h-4 w-4" />
              {t("pages.companies.quotes.show.actions.update_quote")}
            </Link>
          </Button>
        </>
      )}
    </>
  );
};

export { QuoteSpecificSection };
