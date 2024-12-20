import { Button } from "@/components/ui/button";
import { Form, FormMessage } from "@/components/ui/form";
import { FormControl } from "@/components/ui/form";
import { FormItem, FormLabel } from "@/components/ui/form";
import { FormField } from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { zodResolver } from "@hookform/resolvers/zod";
import { TFunction } from "i18next";
import { useForm } from "react-hook-form";
import { useTranslation } from "react-i18next";
import { z } from "zod";

const clientFormSchema = (t: TFunction<"translation">) =>
  z.object({
    name: z.string().min(1, t("form.validation.required")),
    registration_number: z.string().min(1),
    email: z.string().min(1).email(),
    phone: z.string().min(1),
    address_street: z.string().min(1),
    address_city: z.string().min(1),
    address_zipcode: z.string().min(1),
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
};

const ClientForm = ({
  initialValues,
}: {
  initialValues?: Partial<ClientFormType>;
}) => {
  const { t } = useTranslation();
  const i18nFormSchema = clientFormSchema(t);
  const form = useForm<ClientFormType>({
    resolver: zodResolver(i18nFormSchema),
    defaultValues: {
      ...DefaultValues,
      ...initialValues,
    },
  });

  const onSubmit = (values: ClientFormType) => {
    console.log(values);
  };

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-8">
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
        <Button type="submit">
          {t("pages.companies.clients.form.submit")}
        </Button>
      </form>
    </Form>
  );
};

export { ClientForm };
