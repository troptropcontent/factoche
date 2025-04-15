import { Form, FormMessage, FormSubmit } from "@/components/ui/form";
import { FormControl } from "@/components/ui/form";
import { FormItem, FormLabel } from "@/components/ui/form";
import { FormField } from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Api } from "@/lib/openapi-fetch-query-client";
import { zodResolver } from "@hookform/resolvers/zod";
import { useNavigate } from "@tanstack/react-router";
import { TFunction } from "i18next";
import { useForm } from "react-hook-form";
import { useTranslation } from "react-i18next";
import { z } from "zod";

const clientFormSchema = (t: TFunction<"translation">) =>
  z.object({
    name: z.string().min(1, t("form.validation.required")),
    registration_number: z.string().min(1, t("form.validation.required")),
    email: z.string().min(1, t("form.validation.required")).email(),
    phone: z.string().min(1, t("form.validation.required")),
    address_street: z.string().min(1, t("form.validation.required")),
    address_city: z.string().min(1, t("form.validation.required")),
    address_zipcode: z.string().min(1, t("form.validation.required")),
    vat_number: z.string().min(1, t("form.validation.required")),
  });

type ClientFormType = z.infer<ReturnType<typeof clientFormSchema>>;

const DefaultValues: ClientFormType = {
  name: "",
  registration_number: "",
  email: "",
  phone: "",
  address_street: "",
  address_city: "",
  address_zipcode: "",
  vat_number: "",
};

// TODO: Consider refactoring error handling logic into a shared utility
// Current error handling includes field-level validation errors and form submission errors
// Could be extracted to be reused across other forms
const ClientForm = ({
  initialValues,
  companyId,
}: {
  initialValues?: Partial<ClientFormType>;
  companyId: string;
}) => {
  const navigate = useNavigate();
  const { t } = useTranslation();
  const i18nFormSchema = clientFormSchema(t);
  const form = useForm<ClientFormType>({
    resolver: zodResolver(i18nFormSchema),
    defaultValues: {
      ...DefaultValues,
      ...initialValues,
    },
  });

  const createClientMutation = Api.useMutation(
    "post",
    "/api/v1/organization/companies/{company_id}/clients"
  );

  // @ts-expect-error Type 'any' for details parameter is expected since API error response type is not strictly typed
  const setFieldErrors = (details) => {
    Object.entries(details).forEach(([field, issues]) => {
      // @ts-expect-error issues array type is unknown since it comes from API error response
      issues.forEach((issue) =>
        // @ts-expect-error field parameter may not match form field names exactly
        form.setError(field, { message: t(`form.validation.${issue.type}`) })
      );
    });
  };

  // @ts-expect-error handleError parameter type is any since it handles various API error responses
  const handleError = (e) => {
    if (typeof e.response.data == "object") {
      setFieldErrors(e.response.data.details);
    } else {
      form.setError("root", { message: t("form.submitError") });
    }
  };

  const onSubmit = async (values: ClientFormType) => {
    await createClientMutation.mutateAsync(
      { body: values, params: { path: { company_id: Number(companyId) } } },
      {
        onError: handleError,
        onSuccess: () => {
          navigate({
            to: "/companies/$companyId/clients",
            params: { companyId },
          });
        },
      }
    );
  };

  return (
    <Form {...form}>
      <form
        onSubmit={form.handleSubmit(onSubmit)}
        className="container space-y-8"
      >
        <FormField
          control={form.control}
          name="name"
          render={({ field }) => (
            <FormItem>
              <FormLabel>{t("pages.companies.clients.form.name")}</FormLabel>
              <FormControl>
                <Input
                  placeholder={t(
                    "pages.companies.clients.form.name_placeholder"
                  )}
                  {...field}
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <FormField
          control={form.control}
          name="registration_number"
          render={({ field }) => (
            <FormItem>
              <FormLabel>
                {t("pages.companies.clients.form.registration_number")}
              </FormLabel>
              <FormControl>
                <Input
                  placeholder={t(
                    "pages.companies.clients.form.registration_number_placeholder"
                  )}
                  {...field}
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <FormField
          control={form.control}
          name="email"
          render={({ field }) => (
            <FormItem>
              <FormLabel>{t("pages.companies.clients.form.email")}</FormLabel>
              <FormControl>
                <Input
                  placeholder={t(
                    "pages.companies.clients.form.email_placeholder"
                  )}
                  {...field}
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <FormField
          control={form.control}
          name="phone"
          render={({ field }) => (
            <FormItem>
              <FormLabel>{t("pages.companies.clients.form.phone")}</FormLabel>
              <FormControl>
                <Input
                  placeholder={t(
                    "pages.companies.clients.form.phone_placeholder"
                  )}
                  {...field}
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <FormField
          control={form.control}
          name="address_street"
          render={({ field }) => (
            <FormItem>
              <FormLabel>
                {t("pages.companies.clients.form.address_street")}
              </FormLabel>
              <FormControl>
                <Input
                  placeholder={t(
                    "pages.companies.clients.form.address_street_placeholder"
                  )}
                  {...field}
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <FormField
          control={form.control}
          name="address_city"
          render={({ field }) => (
            <FormItem>
              <FormLabel>
                {t("pages.companies.clients.form.address_city")}
              </FormLabel>
              <FormControl>
                <Input
                  placeholder={t(
                    "pages.companies.clients.form.address_city_placeholder"
                  )}
                  {...field}
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <FormField
          control={form.control}
          name="address_zipcode"
          render={({ field }) => (
            <FormItem>
              <FormLabel>
                {t("pages.companies.clients.form.address_zipcode")}
              </FormLabel>
              <FormControl>
                <Input
                  placeholder={t(
                    "pages.companies.clients.form.address_zipcode_placeholder"
                  )}
                  {...field}
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <FormField
          control={form.control}
          name="vat_number"
          render={({ field }) => (
            <FormItem>
              <FormLabel>
                {t("pages.companies.clients.form.vat_number")}
              </FormLabel>
              <FormControl>
                <Input
                  placeholder={t(
                    "pages.companies.clients.form.vat_number_placeholder"
                  )}
                  {...field}
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        {form.formState.errors.root && (
          <FormMessage>{form.formState.errors.root.message}</FormMessage>
        )}
        <FormSubmit type="submit">
          {t("pages.companies.clients.form.submit")}
        </FormSubmit>
      </form>
    </Form>
  );
};

export { ClientForm };
