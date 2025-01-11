import { Button } from "@/components/ui/button";
import { projectFormMachine } from "./project-form.machine";
import { EventFromLogic } from "xstate";
import { useTranslation } from "react-i18next";
import { z } from "zod";
import { step1FormSchema, step2FormSchema } from "./project-form.schema";
import { buildApiRequestBody, computeItemsTotal } from "./project-form.utils";
import {
  Card,
  CardContent,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

import { useQuery } from "@tanstack/react-query";
import { getCompanyClientsQueryOptions } from "@/queries/organization/clients/getCompanyClientsQueryOptions";
import { ItemSummary } from "./private/item-summary";
import { ItemGroupSummary } from "./private/item-group-summary";

const Step3 = ({
  send,
  companyId,
  previousStepsData,
}: {
  send: (e: EventFromLogic<typeof projectFormMachine>) => void;
  companyId: string;
  previousStepsData: z.infer<typeof step1FormSchema> &
    z.infer<typeof step2FormSchema>;
}) => {
  const { t } = useTranslation();
  const { data: clients = [] } = useQuery(
    getCompanyClientsQueryOptions(companyId)
  );
  const client = clients.find(
    (client) => client.id == previousStepsData.client_id
  );

  const createNewProject = () => {
    const apiRequestBody = buildApiRequestBody(previousStepsData);
    console.log("about to send the following body: ", apiRequestBody);
  };

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
                value: previousStepsData.name,
              },
              {
                field: t(
                  "pages.companies.projects.form.basic_info_step.description_input_label"
                ),
                value: previousStepsData.description,
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
                value: previousStepsData.retention_guarantee_rate,
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
        <CardContent>
          {previousStepsData.items.map((item, index) =>
            "items" in item ? (
              <ItemGroupSummary key={index} {...item} />
            ) : (
              <ItemSummary key={index} {...item} />
            )
          )}
        </CardContent>
        <CardFooter className="justify-end">
          <div className="text-right font-semibold text-lg">
            {t(
              "pages.companies.projects.form.confirmation_step.total_project_amount_label",
              {
                total: t("common.number_in_currency", {
                  amount: computeItemsTotal(previousStepsData.items),
                }),
              }
            )}
          </div>
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
        <Button onClick={createNewProject}>
          {t("pages.companies.projects.form.submit_button_label")}
        </Button>
      </div>
    </div>
  );
};

export { Step3 };
