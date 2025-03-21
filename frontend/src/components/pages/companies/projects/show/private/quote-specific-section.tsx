import { Button } from "@/components/ui/button";
import { useToast } from "@/hooks/use-toast";
import { Api } from "@/lib/openapi-fetch-query-client";
import { Link, useNavigate } from "@tanstack/react-router";
import { Download, Loader2 } from "lucide-react";
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
  const { data: quote } = Api.useQuery(
    "get",
    "/api/v1/organization/quotes/{id}",
    { params: { path: { id: quoteId } } },
    { select: ({ result }) => result }
  );

  const { mutate: convertToOrderMutation } = Api.useMutation(
    "post",
    "/api/v1/organization/quotes/{id}/convert_to_order"
  );

  if (quote == undefined) {
    return null;
  }

  const documentUrl = quote.last_version.pdf_url;

  const order = quote.orders[0];
  const convertToOrder = () => {
    const onSuccess = ({
      result: { id: orderId },
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
        to: "/companies/$companyId/orders/$orderId",
        params: {
          companyId: companyId.toString(),
          orderId: orderId.toString(),
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
    convertToOrderMutation(
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
      {order ? (
        <Button variant="default">
          <Link
            to="/companies/$companyId/orders/$orderId"
            params={{
              companyId: companyId.toString(),
              orderId: order.id.toString(),
            }}
          >
            {t("pages.companies.quotes.show.actions.go_order")}
          </Link>
        </Button>
      ) : (
        <Button variant="default" onClick={convertToOrder}>
          {t("pages.companies.quotes.show.actions.convert_to_order")}
        </Button>
      )}
    </>
  );
};

export { QuoteSpecificSection };
