import { Link } from "@tanstack/react-router";

import { Button, LoadingButton } from "@/components/ui/button";
import { Loader2 } from "lucide-react";
import { useToast } from "@/hooks/use-toast";
import { Api } from "@/lib/openapi-fetch-query-client";
import { useNavigate } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";
import { Download } from "lucide-react";

const ProjectShowContentSpecificSection = ({
  draftOrderId,
  companyId,
}: {
  draftOrderId: number;
  companyId: number;
}) => {
  const { toast } = useToast();
  const navigate = useNavigate();
  const { t } = useTranslation();
  const { data: draftOrder } = Api.useQuery(
    "get",
    "/api/v1/organization/draft_orders/{id}",
    { params: { path: { id: draftOrderId } } },
    { select: ({ result }) => result }
  );

  const { mutateAsync: convertToOrderMutationAsync } = Api.useMutation(
    "post",
    "/api/v1/organization/draft_orders/{id}/convert_to_order"
  );

  if (draftOrder == undefined) {
    return null;
  }

  const documentUrl = draftOrder.last_version.pdf_url;

  const order = draftOrder.orders[0];
  const convertOrder = async () => {
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
    await convertToOrderMutationAsync(
      { params: { path: { id: draftOrderId } } },
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
        <>
          <LoadingButton variant="default" onClick={convertOrder}>
            {t("pages.companies.quotes.show.actions.convert_to_order")}
          </LoadingButton>
          {/* <Button asChild variant="outline">
            <Link
              to={"/companies/$companyId/draft_orders/$draftOrder/update"}
              params={{
                companyId: companyId.toString(),
                quoteId: quoteId.toString(),
              }}
            >
              <Pen className="mr-2 h-4 w-4" />
              {t("pages.companies.quotes.show.actions.update_quote")}
            </Link>
          </Button> */}
        </>
      )}
    </>
  );
};

export { ProjectShowContentSpecificSection };
