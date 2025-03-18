import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { useTranslation } from "react-i18next";
import { useInvoiceContentData } from "./hooks";
import { ItemGroupSummary } from "./item-group-summary";

const LoadingContent = () => <Skeleton className="w-full h-4" />;

const UngroupedItemsContent = () => "UngroupedItemsContent";

const GroupedItemsContent = ({
  invoiceContentData,
}: {
  invoiceContentData: NonNullable<
    ReturnType<typeof useInvoiceContentData>["invoiceContentData"]
  >;
}) => {
  return invoiceContentData.groups.map((group) => {
    return (
      <ItemGroupSummary
        key={group.id}
        name={group.name}
        items={invoiceContentData.items.filter(
          (item) => item.groupId == group.id
        )}
      />
    );
  });
};

const LoadedContent = ({
  invoiceContentData,
}: {
  invoiceContentData: NonNullable<
    ReturnType<typeof useInvoiceContentData>["invoiceContentData"]
  >;
}) => {
  return invoiceContentData.groups.length == 0 ? (
    <UngroupedItemsContent />
  ) : (
    <GroupedItemsContent invoiceContentData={invoiceContentData} />
  );
};

const InvoiceContent = ({
  companyId,
  projectId,
  invoiceId,
}: {
  companyId: number;
  projectId: number;
  invoiceId: number;
}) => {
  const { invoiceContentData } = useInvoiceContentData({
    companyId,
    invoiceId,
    projectId,
  });
  const { t } = useTranslation();

  return (
    <Card>
      <CardHeader>
        <CardTitle>
          {t("pages.companies.completion_snapshot.grouped_items_details.title")}
        </CardTitle>
      </CardHeader>
      <CardContent>
        {invoiceContentData == undefined ? (
          <LoadingContent />
        ) : (
          <LoadedContent invoiceContentData={invoiceContentData} />
        )}
      </CardContent>
    </Card>
  );
};

export { InvoiceContent };
