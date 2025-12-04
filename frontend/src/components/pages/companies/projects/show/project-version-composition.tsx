import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";
import { Api } from "@/lib/openapi-fetch-query-client";
import { useTranslation } from "react-i18next";
import { Skeleton } from "@/components/ui/skeleton";
import { ItemGroupSummary } from "../form/private/item-group-summary";
import { useState } from "react";
import { ItemSummary } from "../form/private/item-summary";
import { VersionSelect } from "./version-select";
import { useQueryClient } from "@tanstack/react-query";
import { ProjectVersionExtended } from "../../project-versions/shared/types";

const TotalSection = ({
  projectVersion,
}: {
  projectVersion?: ProjectVersionExtended;
}) => {
  const { t } = useTranslation();
  const TotalLine = ({ label, amount }: { label: string; amount?: number }) => (
    <>
      <Separator className="my-4" />
      <div className="flex justify-between items-center text-lg font-semibold">
        <span>{label}</span>
        <span>
          {amount == undefined ? (
            <Skeleton className="h-6 w-[100px]" />
          ) : (
            t("common.number_in_currency", { amount })
          )}
        </span>
      </div>
    </>
  );

  if (projectVersion == undefined) {
    return (
      <TotalLine
        label={t(
          "pages.companies.projects.show.project_composition.project_total"
        )}
        amount={undefined}
      />
    );
  }

  if (projectVersion.discounts.length == 0) {
    return (
      <TotalLine
        label={t(
          "pages.companies.projects.show.project_composition.project_total"
        )}
        amount={Number(projectVersion.total_excl_tax_amount)}
      />
    );
  }

  return (
    <>
      <TotalLine
        label={t(
          "pages.companies.projects.show.project_composition.project_total_before_discounts"
        )}
        amount={
          Number(projectVersion.total_excl_tax_amount) +
          projectVersion.discounts.reduce(
            (acc, discount) => acc + Number(discount.amount),
            0
          )
        }
      />
      <DiscountsSection discounts={projectVersion.discounts} />
      <TotalLine
        label={t(
          "pages.companies.projects.show.project_composition.project_total_after_discounts"
        )}
        amount={Number(projectVersion.total_excl_tax_amount)}
      />
    </>
  );
};

const DiscountsSection = ({
  discounts,
}: {
  discounts: ProjectVersionExtended["discounts"];
}) => {
  const { t } = useTranslation();
  const sortedDiscounts = discounts.sort((a, b) => a.position - b.position);
  return (
    <>
      <Separator className="my-4" />
      <div className="flex flex-col">
        {sortedDiscounts.map((discount) => {
          return (
            <div className="flex justify-between">
              <p>
                {discount.name}
                {" :"}
              </p>
              <p>
                {"- "}
                {t("common.number_in_currency", {
                  amount: discount.amount,
                })}
              </p>
            </div>
          );
        })}
      </div>
    </>
  );
};

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
        <TotalSection projectVersion={data?.result} />
      </CardContent>
    </Card>
  );
};

export { ProjectVersionComposition };
