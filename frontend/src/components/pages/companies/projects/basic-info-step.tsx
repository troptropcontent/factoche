import { Input } from "@/components/ui/input";
import { SubmitHandler, useForm } from "react-hook-form";

import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Trans, useTranslation } from "react-i18next";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { z } from "zod";
import { Step1FormDataSchema } from "./form-schemas";
import { useQuery } from "@tanstack/react-query";
import { getCompanyClientsQueryOptions } from "@/queries/organization/clients/getCompanyClientsQueryOptions";
import { Button } from "@/components/ui/button";
import { zodResolver } from "@hookform/resolvers/zod";
import { Link, useNavigate } from "@tanstack/react-router";

type Step1FormType = z.infer<typeof Step1FormDataSchema>;
const BasicInfoStep = ({
  companyId,
  initialValues,
}: {
  companyId: string;
  initialValues?: Step1FormType;
}) => {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const { data: clients = [] } = useQuery(
    getCompanyClientsQueryOptions(companyId)
  );
  const form = useForm<Step1FormType>({
    resolver: zodResolver(Step1FormDataSchema),
    defaultValues: {
      name: "",
      description: "",
      client_id: 0,
      retention_guarantee_rate: 0,
      ...initialValues,
    },
  });

  const onSubmit: SubmitHandler<Step1FormType> = (data) => {
    navigate({
      to: "/companies/$companyId/projects/new",
      params: { companyId },
      search: {
        step: 1,
        previousStepFormData: data,
      },
    });
  };
  return (
    <Form {...form}>
      <form
        onSubmit={form.handleSubmit(onSubmit)}
        className="px-6 flex flex-col flex-grow"
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

export { BasicInfoStep };
