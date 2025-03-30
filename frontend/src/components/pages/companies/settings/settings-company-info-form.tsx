import { useFormContext } from "react-hook-form";
import { AddressAutofill } from "@mapbox/search-js-react";
import {
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Grid } from "@/components/ui/grid";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { useTranslation } from "react-i18next";
import { settingsFormSchema } from "./private/schemas";
import { z } from "zod";

export function CompanyInfoForm() {
  const { control } = useFormContext<z.infer<typeof settingsFormSchema>>();
  const { t } = useTranslation();
  return (
    <Grid className="grid-cols-1 md:grid-cols-2 gap-6">
      <FormField
        control={control}
        name="name"
        render={({ field }) => (
          <FormItem>
            <FormLabel>
              {t("pages.companies.settings.forms.general.fields.name")}
            </FormLabel>
            <FormControl>
              <Input
                placeholder={t(
                  "pages.companies.settings.forms.general.fields.name_placeholder"
                )}
                {...field}
              />
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />

      <FormField
        control={control}
        name="registration_number"
        render={({ field }) => (
          <FormItem>
            <FormLabel>
              {t(
                "pages.companies.settings.forms.general.fields.registration_number"
              )}
            </FormLabel>
            <FormControl>
              <Input
                placeholder={t(
                  "pages.companies.settings.forms.general.fields.registration_number_placeholder"
                )}
                {...field}
              />
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />

      <FormField
        control={control}
        name="email"
        render={({ field }) => (
          <FormItem>
            <FormLabel>
              {t("pages.companies.settings.forms.general.fields.email")}
            </FormLabel>
            <FormControl>
              <Input
                type="email"
                placeholder={t(
                  "pages.companies.settings.forms.general.fields.email_placeholder"
                )}
                {...field}
              />
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />

      <FormField
        control={control}
        name="phone"
        render={({ field }) => (
          <FormItem>
            <FormLabel>
              {t("pages.companies.settings.forms.general.fields.phone")}
            </FormLabel>
            <FormControl>
              <Input
                placeholder={t(
                  "pages.companies.settings.forms.general.fields.phone_placeholder"
                )}
                {...field}
              />
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />

      <FormField
        control={control}
        name="address_street"
        render={({ field }) => (
          <FormItem>
            <FormLabel>
              {t(
                "pages.companies.settings.forms.general.fields.address_street"
              )}
            </FormLabel>
            <FormControl>
              <AddressAutofill
                accessToken={import.meta.env.VITE_MAPBOX_ACCESS_TOKEN}
              >
                <Input
                  className="mt-2"
                  placeholder={t(
                    "pages.companies.settings.forms.general.fields.address_street_placeholder"
                  )}
                  autoComplete="address-line1"
                  {...field}
                />
              </AddressAutofill>
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />

      <FormField
        control={control}
        name="address_city"
        render={({ field }) => (
          <FormItem>
            <FormLabel>
              {t("pages.companies.settings.forms.general.fields.address_city")}
            </FormLabel>
            <FormControl>
              <Input
                placeholder={t(
                  "pages.companies.settings.forms.general.fields.address_city_placeholder"
                )}
                autoComplete="address-level2"
                {...field}
              />
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />

      <FormField
        control={control}
        name="address_zipcode"
        render={({ field }) => (
          <FormItem>
            <FormLabel>
              {t(
                "pages.companies.settings.forms.general.fields.address_zipcode"
              )}
            </FormLabel>
            <FormControl>
              <Input
                placeholder={t(
                  "pages.companies.settings.forms.general.fields.address_zipcode_placeholder"
                )}
                autoComplete="postal-code"
                {...field}
              />
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />

      <FormField
        control={control}
        name="legal_form"
        render={({ field }) => (
          <FormItem>
            <FormLabel>
              {t("pages.companies.settings.forms.general.fields.legal_form")}
            </FormLabel>
            <Select onValueChange={field.onChange} defaultValue={field.value}>
              <FormControl>
                <SelectTrigger>
                  <SelectValue
                    placeholder={t(
                      "pages.companies.settings.forms.general.fields.legal_form_placeholder"
                    )}
                  />
                </SelectTrigger>
              </FormControl>
              <SelectContent>
                <SelectItem value="sas">sas</SelectItem>
                <SelectItem value="sarl">sarl</SelectItem>
                <SelectItem value="eurl">eurl</SelectItem>
                <SelectItem value="sa">sa</SelectItem>
                <SelectItem value="auto_entrepreneur">
                  auto entrepreneur
                </SelectItem>
              </SelectContent>
            </Select>
            <FormMessage />
          </FormItem>
        )}
      />

      <FormField
        control={control}
        name="rcs_city"
        render={({ field }) => (
          <FormItem>
            <FormLabel>
              {t("pages.companies.settings.forms.general.fields.rcs_city")}
            </FormLabel>
            <FormControl>
              <Input
                placeholder={t(
                  "pages.companies.settings.forms.general.fields.rcs_city_placeholder"
                )}
                {...field}
              />
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />

      <FormField
        control={control}
        name="rcs_number"
        render={({ field }) => (
          <FormItem>
            <FormLabel>
              {t("pages.companies.settings.forms.general.fields.rcs_number")}
            </FormLabel>
            <FormControl>
              <Input
                placeholder={t(
                  "pages.companies.settings.forms.general.fields.rcs_number_placeholder"
                )}
                {...field}
              />
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />

      <FormField
        control={control}
        name="vat_number"
        render={({ field }) => (
          <FormItem>
            <FormLabel>
              {t("pages.companies.settings.forms.general.fields.vat_number")}
            </FormLabel>
            <FormControl>
              <Input
                placeholder={t(
                  "pages.companies.settings.forms.general.fields.vat_number_placeholder"
                )}
                {...field}
              />
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />

      <FormField
        control={control}
        name="capital_amount"
        render={({ field }) => (
          <FormItem>
            <FormLabel>
              {t(
                "pages.companies.settings.forms.general.fields.capital_amount"
              )}
            </FormLabel>
            <FormControl>
              <Input
                placeholder={t(
                  "pages.companies.settings.forms.general.fields.capital_amount_placeholder"
                )}
                {...field}
              />
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />
    </Grid>
  );
}
