import { useFormContext } from "react-hook-form";
import {
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";

import { Label } from "@/components/ui/label";
import { Checkbox } from "@/components/ui/checkbox";
import { RichTextInput } from "@/components/ui/rich-text-input";
import { useTranslation } from "react-i18next";
import { z } from "zod";
import { settingsFormSchema } from "./private/schemas";

const paymentMethods = [
  { id: "transfer", label: "Bank Transfer" },
  { id: "card", label: "Credit Card" },
  { id: "cash", label: "Cash" },
];

export function BillingConfigForm() {
  const { control } = useFormContext<z.infer<typeof settingsFormSchema>>();
  const { t } = useTranslation();

  return (
    <div className="space-y-6">
      <FormField
        control={control}
        name="configs.payment_term_days"
        render={({ field }) => (
          <FormItem>
            <FormLabel>
              {t(
                "pages.companies.settings.forms.billing.fields.payment_term_days"
              )}
            </FormLabel>
            <FormControl>
              <Input
                type="number"
                {...field}
                onChange={(e) => field.onChange(e.target.valueAsNumber)}
              />
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />

      <FormField
        control={control}
        name="configs.payment_term_accepted_methods"
        render={({ field }) => (
          <FormItem>
            <FormLabel>
              {t(
                "pages.companies.settings.forms.billing.fields.payment_term_accepted_methods"
              )}
            </FormLabel>
            <FormControl>
              <div className="space-y-3">
                <div className="grid grid-cols-2 sm:grid-cols-3 gap-4">
                  {paymentMethods.map((method) => (
                    <div
                      key={method.id}
                      className="flex items-center space-x-2"
                    >
                      <Checkbox
                        id={method.id}
                        checked={field.value.includes(
                          method.id as "transfer" | "card" | "cash"
                        )}
                        onCheckedChange={(checked) => {
                          const currentValues = field.value
                            ? [...field.value]
                            : [];
                          if (checked) {
                            field.onChange([...currentValues, method.id]);
                          } else {
                            field.onChange(
                              currentValues.filter(
                                (value) => value !== method.id
                              )
                            );
                          }
                        }}
                      />
                      <Label htmlFor={method.id}>{method.label}</Label>
                    </div>
                  ))}
                </div>
              </div>
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />

      <FormField
        control={control}
        name={"configs.default_vat_rate"}
        render={({ field }) => (
          <FormItem>
            <FormLabel>
              {t(
                "pages.companies.settings.forms.billing.fields.default_vat_rate"
              )}
            </FormLabel>
            <div className="relative w-24">
              <FormControl>
                <Input
                  type="number"
                  min={0}
                  max={100}
                  {...field}
                  onChange={(e) => field.onChange(Number(e.target.value))}
                />
              </FormControl>
              <span className="absolute inset-y-0 right-6 flex items-center pr-2 pointer-events-none">
                %
              </span>
            </div>
            <FormMessage />
          </FormItem>
        )}
      />
      <FormField
        control={control}
        name="configs.general_terms_and_conditions"
        render={({ field }) => (
          <FormItem>
            <FormLabel>
              {t(
                "pages.companies.settings.forms.billing.fields.general_terms_and_condition"
              )}
            </FormLabel>
            <RichTextInput input={field.name} />
            <FormMessage />
          </FormItem>
        )}
      />
    </div>
  );
}
