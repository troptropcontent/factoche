import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";
import { Api } from "@/lib/openapi-fetch-query-client";
import { useTranslation } from "react-i18next";
import { Skeleton } from "@/components/ui/skeleton";
import { ItemGroupSummary } from "../form/private/item-group-summary";
import { useMemo, useState } from "react";
import { ItemSummary } from "../form/private/item-summary";
import { VersionSelect } from "./version-select";
import { useQueryClient } from "@tanstack/react-query";

const ProjectVersionComposition = ({
  routeParams: { companyId, projectId },
  initialVersionId,
}: {
  routeParams: { companyId: number; projectId: number };
  initialVersionId: number;
}) => {
  const [currentVersionId, setCurrentVersionId] = useState(initialVersionId);
  const { data } = Api.useQuery(
    "get",
    "/api/v1/organization/project_versions/{id}",
    {
      params: {
        path: {
          id: currentVersionId,
        },
      },
    }
  );
  const queryClient = useQueryClient();
  const handleVersionChange = async (value: string) => {
    // Preload the query needed in the component to avoid blink loading
    await queryClient.ensureQueryData(
      Api.queryOptions("get", "/api/v1/organization/project_versions/{id}", {
        params: {
          path: {
            id: Number.parseInt(value, 10),
          },
        },
      })
    );
    setCurrentVersionId(Number.parseInt(value, 10));
  };
  const { t } = useTranslation();

  const totalAmount = useMemo(() => {
    if (data == undefined) {
      return 0;
    }

    const computeItemSum = (
      items: { unit_price_amount: string; quantity: number }[]
    ) => {
      return items.reduce(
        (prev, current) =>
          prev + Number(current.unit_price_amount) * current.quantity,
        0
      );
    };

    const itemGroupTotalCents = data.result.item_groups.reduce(
      (prev, current) => {
        return prev + computeItemSum(current.grouped_items);
      },
      0
    );

    const ungroupedItemsTotalCents = computeItemSum(
      data.result.ungrouped_items
    );

    return itemGroupTotalCents + ungroupedItemsTotalCents;
  }, [data]);

  return (
    <Card>
      <CardHeader className="flex-row space-y-0">
        <CardTitle className="flex-grow my-auto text-xl">
          {t("pages.companies.projects.show.project_composition.title")}
        </CardTitle>
        <VersionSelect
          routeParams={{ companyId, orderId: projectId }}
          onValueChange={handleVersionChange}
          versionId={currentVersionId}
        />
      </CardHeader>
      <CardContent className="space-y-6">
        {data == undefined
          ? [1, 2, 3].map((index) => (
              <Card key={index} className="mb-6">
                <CardHeader>
                  <Skeleton className="h-6 w-[200px]" />
                </CardHeader>
                <CardContent>
                  <Skeleton className="h-[100px] w-full" />
                </CardContent>
              </Card>
            ))
          : [
              ...data.result.item_groups.map((item_group) => (
                <ItemGroupSummary
                  key={item_group.id}
                  name={item_group.name}
                  description={item_group.name}
                  items={item_group.grouped_items.map((item) => ({
                    ...item,
                    unit_price_amount: Number(item.unit_price_amount),
                    tax_rate: Number(item.tax_rate),
                  }))}
                />
              )),
              ...data.result.ungrouped_items.map((ungrouped_item) => (
                <ItemSummary
                  key={ungrouped_item.id}
                  {...ungrouped_item}
                  unit_price={Number(ungrouped_item.unit_price_amount)}
                />
              )),
            ]}
        <Separator className="my-4" />
        <div className="flex justify-between items-center text-lg font-semibold">
          <span>
            {t(
              "pages.companies.projects.show.project_composition.project_total"
            )}
          </span>
          <span>
            {data == undefined ? (
              <Skeleton className="h-6 w-[100px]" />
            ) : (
              t("common.number_in_currency", {
                amount: totalAmount,
              })
            )}
          </span>
        </div>
      </CardContent>
    </Card>
  );
};

export { ProjectVersionComposition };
