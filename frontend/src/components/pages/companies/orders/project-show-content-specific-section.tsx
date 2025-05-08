import { Button } from "@/components/ui/button";
import { Link } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";
import { Api } from "@/lib/openapi-fetch-query-client";
import { Download, Loader2, Pen } from "lucide-react";
import { useChannelSubscription } from "@/hooks/use-channel-subscription";
import InvoicingSection from "./private/invoicing-section";

const ProjectShowContentSpecificSection = ({
  orderId,
  companyId,
}: {
  orderId: number;
  companyId: number;
}) => {
  const { t } = useTranslation();
  const { data: order, refetch } = Api.useQuery(
    "get",
    "/api/v1/organization/orders/{id}",
    { params: { path: { id: orderId } } },
    { select: ({ result }) => result }
  );

  useChannelSubscription<{
    type: "PDF_GENERATED";
    data: { record_class: string; record_id: number };
  }>(`NotificationsChannel`, (data) => {
    if (
      data.type == "PDF_GENERATED" &&
      data.data.record_id === order?.last_version.id
    ) {
      refetch();
    }
  });

  return (
    <>
      <Button asChild variant="outline">
        {order?.last_version?.pdf_url != undefined ? (
          <Link
            to={`${import.meta.env.VITE_API_BASE_URL}${order.last_version.pdf_url}`}
          >
            <Download className="mr-2 h-4 w-4" />
            {t("pages.companies.orders.show.actions.download_order_pdf")}
          </Link>
        ) : (
          <Link disabled>
            <Loader2 className="mr-2 h-4 w-4 animate-spin" />
            {t("pages.companies.orders.show.actions.order_pdf_unavailable")}
          </Link>
        )}
      </Button>
      <Button asChild variant="outline">
        <Link
          to={"/companies/$companyId/orders/$orderId/update"}
          params={{
            companyId: companyId.toString(),
            orderId: orderId.toString(),
          }}
        >
          <Pen className="mr-2 h-4 w-4" />
          {t("pages.companies.orders.show.actions.update_order")}
        </Link>
      </Button>
      <InvoicingSection companyId={companyId} orderId={orderId} />
    </>
  );
};

export { ProjectShowContentSpecificSection };
