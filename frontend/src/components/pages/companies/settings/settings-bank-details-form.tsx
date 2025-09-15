import { useFormContext, useFieldArray } from "react-hook-form";
import {
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Grid } from "@/components/ui/grid";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { useTranslation } from "react-i18next";
import { Trash2, Plus } from "lucide-react";
import { z } from "zod";
import { settingsFormSchema } from "./private/schemas";

export function BankDetailsForm() {
  const { control } = useFormContext<z.infer<typeof settingsFormSchema>>();
  const { t } = useTranslation();

  const { fields, append, remove } = useFieldArray({
    control,
    name: "bank_details_attributes"
  });

  const addBankDetail = () => {
    append({
      name: "",
      iban: "",
      bic: "",
      record_id: null
    });
  };

  return (
    <div className="space-y-6">
      {fields.length === 0 && (
        <div className="text-center py-8">
          <p className="text-muted-foreground mb-4">
            {t("pages.companies.settings.forms.bank_details.no_bank_details")}
          </p>
          <Button onClick={addBankDetail} variant="outline">
            <Plus className="h-4 w-4 mr-2" />
            {t("pages.companies.settings.forms.bank_details.add_bank_detail")}
          </Button>
        </div>
      )}

      {fields.map((array_input, index) => (
        <Card key={array_input.id}>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-base">
              {t("pages.companies.settings.forms.bank_details.bank_detail_title", {
                number: index + 1
              })}
            </CardTitle>
            {array_input.record_id == null && (
              <Button
                onClick={() => remove(index)}
                variant="ghost"
                size="sm"
                className="text-destructive hover:text-destructive"
              >
                <Trash2 className="h-4 w-4" />
              </Button>
            )}
          </CardHeader>
          <CardContent>
            <Grid className="grid-cols-1 md:grid-cols-2 gap-6">
              <FormField
                control={control}
                name={`bank_details_attributes.${index}.name`}
                render={({ field }) => (
                  <FormItem className="col-span-2">
                    <FormLabel>
                      {t("pages.companies.settings.forms.bank_details.fields.name")}
                    </FormLabel>
                    <FormControl>
                      <Input
                        placeholder={t(
                          "pages.companies.settings.forms.bank_details.fields.name_placeholder"
                        )}
                        disabled={array_input.record_id != null}
                        {...field}
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={control}
                name={`bank_details_attributes.${index}.iban`}
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>
                      {t("pages.companies.settings.forms.bank_details.fields.iban")}
                    </FormLabel>
                    <FormControl>
                      <Input
                        placeholder={t(
                          "pages.companies.settings.forms.bank_details.fields.iban_placeholder"
                        )}
                        disabled={array_input.record_id != null}
                        {...field}
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={control}
                name={`bank_details_attributes.${index}.bic`}
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>
                      {t("pages.companies.settings.forms.bank_details.fields.bic")}
                    </FormLabel>
                    <FormControl>
                      <Input
                        placeholder={t(
                          "pages.companies.settings.forms.bank_details.fields.bic_placeholder"
                        )}
                        disabled={array_input.record_id != null}
                        {...field}
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />
            </Grid>
          </CardContent>
        </Card>
      ))}

      {fields.length > 0 && (
        <div className="flex justify-center">
          <Button onClick={addBankDetail} variant="outline" asChild>
            <div>
              <Plus className="h-4 w-4 mr-2" />
              {t("pages.companies.settings.forms.bank_details.add_bank_detail")}
            </div>
          </Button>
        </div>
      )}
    </div>
  );
}