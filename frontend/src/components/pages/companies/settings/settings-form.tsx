import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
} from "@/components/ui/card";
import { Form, FormSubmit } from "@/components/ui/form";
import { CompanyInfoForm } from "./settings-company-info-form";
import { useSettingsFormInitialValues } from "./private/hooks";
import { SettingsForm as SettingsFormType } from "./private/types";
import { settingsFormSchema } from "./private/schemas";
import { BillingConfigForm } from "./settings-billing-info-form";
import { BankDetailsForm } from "./settings-bank-details-form";
import { t } from "i18next";
import { z } from "zod";
import { Api } from "@/lib/openapi-fetch-query-client";
import { useToast } from "@/hooks/use-toast";

export function SettingsForm({ companyId }: { companyId: number }) {
  const { toast } = useToast();
  const initialValues = useSettingsFormInitialValues({ companyId: companyId });
  const form = useForm<SettingsFormType>({
    resolver: zodResolver(settingsFormSchema),
    defaultValues: initialValues,
  });
  const { mutateAsync: updateCompanyAsync } = Api.useMutation(
    "put",
    "/api/v1/organization/companies/{id}"
  );

  async function onSubmit(data: z.infer<typeof settingsFormSchema>) {
    await updateCompanyAsync(
      {
        params: { path: { id: Number(companyId) } },
        body: {
          ...data,
          capital_amount: Number(data.capital_amount),
          bank_details_attributes: data.bank_details_attributes.reduce((memo, bank_detail)=> bank_detail.record_id == null ? [...memo, bank_detail] : memo, [] as typeof data.bank_details_attributes),
          configs: {
            ...data.configs,
            default_vat_rate: data.configs.default_vat_rate / 100,
          },
        },
      },
      {
        onError: () => {
          toast({
            variant: "destructive",
            title: t("pages.companies.settings.forms.shared.error_toast_title"),
            description: t(
              "pages.companies.settings.forms.shared.error_toast_description"
            ),
          });
        },
        onSuccess: () => {
          toast({
            variant: "success",
            title: t(
              "pages.companies.settings.forms.shared.success_toast_title"
            ),
            description: t(
              "pages.companies.settings.forms.shared.success_toast_description"
            ),
          });
        },
      }
    );
  }

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-8">
        <Tabs defaultValue="company-info" className="w-full">
          <TabsList className="grid w-full grid-cols-3">
            <TabsTrigger value="company-info">
              {t("pages.companies.settings.forms.general.title")}
            </TabsTrigger>
            <TabsTrigger value="billing-config">
              {t("pages.companies.settings.forms.billing.title")}
            </TabsTrigger>
            <TabsTrigger value="bank-details">
              {t("pages.companies.settings.forms.bank_details.title")}
            </TabsTrigger>
          </TabsList>

          <TabsContent value="company-info">
            <Card>
              <CardHeader>
                <CardDescription>
                  {t("pages.companies.settings.forms.general.description")}
                </CardDescription>
              </CardHeader>
              <CardContent>
                <CompanyInfoForm />
              </CardContent>
              <CardFooter className="flex justify-end">
                <FormSubmit>
                  {t("pages.companies.settings.forms.shared.submit")}
                </FormSubmit>
              </CardFooter>
            </Card>
          </TabsContent>

          <TabsContent value="billing-config">
            <Card>
              <CardHeader>
                <CardDescription>
                  {t("pages.companies.settings.forms.billing.description")}
                </CardDescription>
              </CardHeader>
              <CardContent>
                <BillingConfigForm />
              </CardContent>
              <CardFooter className="flex justify-end">
                <FormSubmit>
                  {t("pages.companies.settings.forms.shared.submit")}
                </FormSubmit>
              </CardFooter>
            </Card>
          </TabsContent>

          <TabsContent value="bank-details">
            <Card>
              <CardHeader>
                <CardDescription>
                  {t("pages.companies.settings.forms.bank_details.description")}
                </CardDescription>
              </CardHeader>
              <CardContent>
                <BankDetailsForm />
              </CardContent>
              <CardFooter className="flex justify-end">
                <FormSubmit>
                  {t("pages.companies.settings.forms.shared.submit")}
                </FormSubmit>
              </CardFooter>
            </Card>
          </TabsContent>
        </Tabs>
      </form>
    </Form>
  );
}
