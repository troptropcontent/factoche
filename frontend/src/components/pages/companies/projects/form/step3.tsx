import { Button } from "@/components/ui/button";
import { projectFormMachine } from "./project-form.machine";
import { EventFromLogic } from "xstate";
import { useTranslation } from "react-i18next";
import { z } from "zod";
import { step1FormSchema, step2FormSchema } from "./project-form.schema";
import {
  Card,
  CardContent,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { ItemGroupSummary } from "./private/item-group-summary";
import { Api } from "@/lib/openapi-fetch-query-client";
import { useNavigate } from "@tanstack/react-router";
import { computeTotal } from "./private/utils";
import { useToast } from "@/hooks/use-toast";

const Step3 = ({
  send,
  companyId,
  previousStepsData: inputs,
}: {
  send: (e: EventFromLogic<typeof projectFormMachine>) => void;
  companyId: string;
  previousStepsData: z.infer<typeof step1FormSchema> &
    z.infer<typeof step2FormSchema>;
}) => {
  const { t } = useTranslation();
  const { mutate } = Api.useMutation(
    "post",
    "/api/v1/organization/companies/{company_id}/clients/{client_id}/quotes"
  );

  const { data: clients = [] } = Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/clients",
    {
      params: {
        path: { company_id: Number(companyId) },
      },
    }
  );

  const { toast } = useToast();
  const navigate = useNavigate();

  const client = clients.find((client) => client.id == inputs.client_id);

  const createNewProject = (clientId: number) => {
    mutate(
      {
        body: {
          ...inputs,
          retention_guarantee_rate: inputs.retention_guarantee_rate / 100,
          items: inputs.items.map((input) => ({
            ...input,
            tax_rate: input.tax_rate / 100,
          })),
        },
        params: {
          path: { company_id: Number(companyId), client_id: clientId },
        },
      },
      {
        onSuccess: ({ result: { id } }) => {
          toast({
            variant: "success",
            title: t(
              "pages.companies.projects.form.confirmation_step.toast.success_toast_title"
            ),
            description: t(
              "pages.companies.projects.form.confirmation_step.toast.success_toast_description"
            ),
          });
          navigate({
            to: "/companies/$companyId/quotes/$quoteId",
            params: { companyId: companyId, quoteId: id.toString() },
          });
        },
        onError: () => {
          toast({
            variant: "destructive",
            title: t(
              "pages.companies.projects.form.confirmation_step.toast.error_toast_title"
            ),
            description: t(
              "pages.companies.projects.form.confirmation_step.toast.error_toast_description"
            ),
          });
        },
      }
    );
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
          <div className="text-right font-semibold text-lg">
            {t(
              "pages.companies.projects.form.confirmation_step.total_project_amount_label",
              {
                total: t("common.number_in_currency", {
                  amount: computeTotal(inputs.items),
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
        <Button onClick={() => createNewProject(inputs.client_id)}>
          {t("pages.companies.projects.form.submit_button_label")}
        </Button>
      </div>
    </div>
  );
};

export { Step3 };
