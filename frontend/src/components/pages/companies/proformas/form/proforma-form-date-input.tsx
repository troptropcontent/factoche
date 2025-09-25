import { Card, CardContent, CardTitle } from "@/components/ui/card";
import { useTranslation } from "react-i18next";
import {
  FormControl,
  FormField,
  FormItem,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { useFormContext } from "react-hook-form";
import { z } from "zod";
import { proformaFormSchema } from "./proforma-form-schema";

const ProformaFormDateInput = () => {
  const { t } = useTranslation();
  const { control, getValues } =
    useFormContext<z.infer<typeof proformaFormSchema>>();
  const values = getValues();
  console.log({ values });
  return (
    <Card>
      <CardContent className="flex pt-6 justify-between">
        <CardTitle className="my-auto">
          {t("pages.companies.projects.invoices.completion_snapshot.form.date")}
          {" :"}
        </CardTitle>
        <FormField
          control={control}
          name="issue_date"
          render={({ field }) => (
            <FormItem>
              <FormControl>
                <Input type="date" className="w-fit" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
      </CardContent>
    </Card>
  );
};

export { ProformaFormDateInput };
