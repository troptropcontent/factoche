import { Button, LoadingButton } from "@/components/ui/button";
import { projectFormMachine } from "./project-form.machine";
import { EventFromLogic } from "xstate";
import { useTranslation } from "react-i18next";
import { z } from "zod";
import {
  formSchema,
  step1FormSchema,
  step2FormSchema,
} from "./project-form.schema";
import {
  Card,
  CardContent,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { ItemGroupSummary } from "./private/item-group-summary";
import { Api } from "@/lib/openapi-fetch-query-client";
import {
  computeDiscountAmounts,
  computeGrossTotal,
  computeNetTotal,
} from "./private/utils";
import { ReactNode } from "@tanstack/react-router";

const TotalFooter = ({
  inputs,
}: {
  inputs: z.infer<typeof step2FormSchema>;
}) => {
  const TotalLine = ({ children }: { children: ReactNode }) => (
    <p className="text-right font-semibold text-lg">{children}</p>
  );
  const { t } = useTranslation();
  const totalBeforeDiscounts = computeGrossTotal(inputs.items);
  const discountAmounts = computeDiscountAmounts(
    totalBeforeDiscounts,
    inputs.discounts
  );
  const totalAfterDiscounts = computeNetTotal(inputs.items, inputs.discounts);

  if (inputs.discounts.length === 0) {
    return (
      <TotalLine>
        {t(
          "pages.companies.projects.form.confirmation_step.total_project_amount_label",
          {
            total: t("common.number_in_currency", {
              amount: totalBeforeDiscounts,
            }),
          }
        )}
      </TotalLine>
    );
  }

  return (
    <div className="flex flex-col items-end">
      <TotalLine>
        {t(
          "pages.companies.projects.form.confirmation_step.total_project_amount_before_discounts_label",
          {
            total: t("common.number_in_currency", {
              amount: totalBeforeDiscounts,
            }),
          }
        )}
      </TotalLine>
      {inputs.discounts.map((discount) => (
        <div className="flex italic">
          <p>
            {discount.name}
            {" : -"}
          </p>
          <p>
            {t("common.number_in_currency", {
              amount: discountAmounts[discount.position],
            })}
          </p>
        </div>
      ))}
      <TotalLine>
        {t(
          "pages.companies.projects.form.confirmation_step.total_project_amount_after_discounts_label",
          {
            total: t("common.number_in_currency", {
              amount: totalAfterDiscounts,
            }),
          }
        )}
      </TotalLine>
    </div>
  );
};

const Step3 = ({
  send,
  companyId,
  previousStepsData: inputs,
  submitFunction,
}: {
  send: (e: EventFromLogic<typeof projectFormMachine>) => void;
  companyId: string;
  previousStepsData: z.infer<typeof step1FormSchema> &
    z.infer<typeof step2FormSchema>;
  submitFunction: (data: z.infer<typeof formSchema>) => void;
}) => {
  const { t } = useTranslation();

  const { data: clients = [] } = Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/clients",
    {
      params: {
        path: { company_id: Number(companyId) },
      },
    }
  );

  const client = clients.find((client) => client.id == inputs.client_id);

  const handleSublmit = async () => submitFunction(inputs);
  return (
    <div className="px-6 flex flex-col flex-grow gap-4">
      <Card>
        <CardHeader>
          <CardTitle>
            {t(
              `pages.companies.projects.form.basic_info_step.progress_bar_label`
            )}
          </CardTitle>
        </CardHeader>
        <CardContent>
          <dl className="grid grid-cols-2 gap-4">
            {[
              {
                field: t(
                  "pages.companies.projects.form.basic_info_step.name_input_label"
                ),
                value: inputs.name,
              },
              {
                field: t(
                  "pages.companies.projects.form.basic_info_step.description_input_label"
                ),
                value: inputs.description,
              },
              {
                field: t(
                  "pages.companies.projects.form.basic_info_step.client_id_input_label"
                ),
                value: client?.name,
              },
              {
                field: t(
                  "pages.companies.projects.form.basic_info_step.retention_guarantee_rate_input_label"
                ),
                value: inputs.retention_guarantee_rate,
              },
            ].map((data) => (
              <div>
                <dt className="font-semibold">{data.field}:</dt>
                <dd>{data.value}</dd>
              </div>
            ))}
          </dl>
        </CardContent>
      </Card>
      <Card>
        <CardHeader>
          <CardTitle>
            {t(
              `pages.companies.projects.form.composition_step.progress_bar_label`
            )}
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          {inputs.groups.map((group) => (
            <ItemGroupSummary
              key={group.uuid}
              {...group}
              items={inputs.items.filter(
                (item) => item.group_uuid == group.uuid
              )}
            />
          ))}
        </CardContent>
        <CardFooter className="justify-end">
          <TotalFooter inputs={inputs} />
        </CardFooter>
      </Card>
      <div className="flex justify-between mt-auto items-center">
        <Button
          onClick={() => {
            send({
              type: "GO_FROM_STEP_3_TO_STEP_2",
            });
          }}
        >
          {t("pages.companies.projects.form.previous_button_label")}
        </Button>

        <LoadingButton onClick={handleSublmit}>
          {t("pages.companies.projects.form.submit_button_label")}
        </LoadingButton>
      </div>
    </div>
  );
};

export { Step3 };
