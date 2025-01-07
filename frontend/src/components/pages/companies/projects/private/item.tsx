import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { ProjectFormType } from "../project-form";
import { useFormContext } from "react-hook-form";
import { useTranslation } from "react-i18next";

const Item = ({
  parentFieldName,
  index,
}: {
  index: number;
  parentFieldName:
    | `project_version_attributes.item_groups_attributes.${number}.items_attributes`
    | `project_version_attributes.items_attributes`;
}) => {
  const fieldName = `${parentFieldName}.${index}` as const;
  const { register, watch } = useFormContext<ProjectFormType>();
  const quantityFieldName = `${fieldName}.quantity` as const;
  const quantityInput = watch(quantityFieldName);
  const unitPriceFieldName = `${fieldName}.unit_price` as const;
  const unitPriceInput = watch(unitPriceFieldName);
  const { t } = useTranslation();
  return (
    <Card key={fieldName} className="mb-4 last:mb-0">
      <CardContent className="pt-6">
        <div className="grid grid-cols-4 gap-4">
          <div className="col-span-full">
            <Label htmlFor={`${fieldName}.name`}>
              {t("pages.companies.projects.form.item_name_input_label")}
            </Label>
            <Input
              id={`${fieldName}.name`}
              {...register(`${fieldName}.name`)}
              placeholder={t(
                "pages.companies.projects.form.item_name_input_placeholder"
              )}
            />
          </div>
          <div>
            <Label htmlFor={quantityFieldName}>
              {t("pages.companies.projects.form.item_quantity_input_label")}
            </Label>
            <Input
              id={quantityFieldName}
              type="number"
              {...register(quantityFieldName, { valueAsNumber: true })}
            />
          </div>
          <div>
            <Label htmlFor={`${fieldName}.unit`}>
              {t("pages.companies.projects.form.item_unit_input_label")}
            </Label>
            <Input
              id={`${fieldName}.unit`}
              placeholder={t(
                "pages.companies.projects.form.item_unit_input_label"
              )}
              {...register(`${fieldName}.unit`)}
            />
          </div>
          <div>
            <Label htmlFor={`${fieldName}.price`}>
              {t("pages.companies.projects.form.item_unit_price_input_label")}
            </Label>
            <Input
              id={`${fieldName}.price`}
              type="number"
              step="0.01"
              {...register(`${fieldName}.unit_price`, { valueAsNumber: true })}
            />
          </div>
          <div>
            <Label>{t("pages.companies.projects.form.item_total_label")}</Label>
            <Input
              disabled
              value={t("common.number_in_currency", {
                amount: unitPriceInput * quantityInput,
              })}
            />
          </div>
        </div>
      </CardContent>
    </Card>
  );
};

export { Item };
