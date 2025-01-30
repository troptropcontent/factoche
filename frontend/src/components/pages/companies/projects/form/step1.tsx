import { projectFormMachine } from "./project-form.machine";
import { type EventFromLogic } from "xstate";
import { Button } from "@/components/ui/button";
import { z } from "zod";
import { step1FormSchema } from "./project-form.schema";
import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Trans, useTranslation } from "react-i18next";
import {
  Select,
  SelectItem,
  SelectContent,
  SelectValue,
  SelectTrigger,
} from "@/components/ui/select";
import { Link } from "@tanstack/react-router";
import { Api } from "@/lib/openapi-fetch-query-client";

const Step1 = ({
  send,
  companyId,
  initialValues,
}: {
  send: (e: EventFromLogic<typeof projectFormMachine>) => void;
  companyId: string;
  initialValues?: z.infer<typeof step1FormSchema>;
}) => {
  const { t } = useTranslation();
  const { data: clients = [] } = Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/clients",
    { params: { path: { company_id: Number(companyId) } } }
  );
  const form = useForm<z.infer<typeof step1FormSchema>>({
    resolver: zodResolver(step1FormSchema),
    defaultValues: initialValues,
  });

  const onSubmit = (data: z.infer<typeof step1FormSchema>) => {
    send({
      type: "GO_FROM_STEP_1_TO_STEP_2",
      formData: data,
    });
  };

  return (
    <Form {...form}>
      <form
        onSubmit={form.handleSubmit(onSubmit)}
        className="px-6 flex flex-col flex-grow gap-4"
      >
        <FormField
          control={form.control}
          name="name"
          render={({ field }) => (
            <FormItem>
              <FormLabel>
                {t(
                  "pages.companies.projects.form.basic_info_step.name_input_label"
                )}
              </FormLabel>
              <FormControl>
                <Input
                  placeholder={t(
                    "pages.companies.projects.form.basic_info_step.name_input_placeholder"
                  )}
                  {...field}
                />
              </FormControl>
              <FormDescription>
                {t(
                  "pages.companies.projects.form.basic_info_step.name_input_description"
                )}
              </FormDescription>
              <FormMessage />
            </FormItem>
          )}
        />
        <FormField
          control={form.control}
          name="description"
          render={({ field }) => (
            <FormItem>
              <FormLabel>
                {t(
                  "pages.companies.projects.form.basic_info_step.description_input_label"
                )}
              </FormLabel>
              <FormControl>
                <Input
                  placeholder={t(
                    "pages.companies.projects.form.basic_info_step.description_input_placeholder"
                  )}
                  {...field}
                />
              </FormControl>
              <FormDescription>
                {t(
                  "pages.companies.projects.form.basic_info_step.description_input_description"
                )}
              </FormDescription>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="client_id"
          render={({ field }) => (
            <FormItem>
              <FormLabel>
                {t(
                  "pages.companies.projects.form.basic_info_step.client_id_input_label"
                )}
              </FormLabel>
              <Select
                onValueChange={(v) => field.onChange(Number(v))}
                defaultValue={field.value.toString()}
              >
                <FormControl>
                  <SelectTrigger>
                    <SelectValue
                      placeholder={t(
                        "pages.companies.projects.form.basic_info_step.client_id_input_placeholder"
                      )}
                    />
                  </SelectTrigger>
                </FormControl>
                <SelectContent>
                  {clients.map((client) => (
                    <SelectItem
                      key={`client-select-${client.id}`}
                      value={client.id.toString()}
                    >
                      {client.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
              <FormDescription>
                <Trans
                  i18nKey="pages.companies.projects.form.basic_info_step.client_id_input_description"
                  values={{ what: "world" }}
                  components={{
                    a: (
                      <Link
                        to="/companies/$companyId/clients"
                        params={{ companyId }}
                        className="underline"
                      />
                    ),
                  }}
                />
              </FormDescription>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="retention_guarantee_rate"
          render={({ field }) => (
            <FormItem>
              <FormLabel>
                {t(
                  "pages.companies.projects.form.basic_info_step.retention_guarantee_rate_input_label"
                )}
              </FormLabel>
              <FormControl>
                <Input
                  {...field}
                  type="number"
                  onChange={(e) => field.onChange(Number(e.target.value))}
                />
              </FormControl>
              <FormDescription>
                {t(
                  "pages.companies.projects.form.basic_info_step.retention_guarantee_rate_input_description"
                )}
              </FormDescription>
              <FormMessage />
            </FormItem>
          )}
        />

        <div className="flex justify-between mt-auto">
          <Button disabled>
            {t("pages.companies.projects.form.previous_button_label")}
          </Button>
          <Button type="submit">
            {t("pages.companies.projects.form.next_button_label")}
          </Button>
        </div>
      </form>
    </Form>
  );
};

export { Step1 };
