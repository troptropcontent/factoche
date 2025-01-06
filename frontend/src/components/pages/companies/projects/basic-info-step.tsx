import { Input } from "@/components/ui/input";

import {
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { useForm, useFormContext } from "react-hook-form";
import { ProjectFormType } from "./project-form";
import { useTranslation } from "react-i18next";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

const BasicInfoStep = ({
  clients,
}: {
  clients: Array<{ id: number; name: string }>;
}) => {
  const { control } = useFormContext<ProjectFormType>();
  const { t } = useTranslation();

  return (
    <>
      <FormField
        control={control}
        name="name"
        render={({ field }) => (
          <FormItem>
            <FormLabel>{t("pages.companies.projects.form.name")}</FormLabel>
            <FormControl>
              <Input
                placeholder={t(
                  "pages.companies.projects.form.name_placeholder"
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
        name="description"
        render={({ field }) => (
          <FormItem>
            <FormLabel>
              {t("pages.companies.projects.form.description")}
            </FormLabel>
            <FormControl>
              <Input
                placeholder={t(
                  "pages.companies.projects.form.description_placeholder"
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
        name="project_version_attributes.retention_guarantee_rate"
        render={({ field }) => (
          <FormItem>
            <FormLabel>
              {t("pages.companies.projects.form.retention_guarantee_rate")}
            </FormLabel>
            <FormControl>
              <Input
                type="number"
                {...field}
                min={0}
                max={100}
                onChange={(e) => field.onChange(Number(e.target.value))}
              />
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />
      <FormField
        control={control}
        name="client_id"
        render={({ field }) => (
          <FormItem>
            <FormLabel>
              {t("pages.companies.projects.form.client_id")}
            </FormLabel>
            <FormControl>
              <Select onValueChange={field.onChange}>
                <SelectTrigger>
                  <SelectValue
                    placeholder={t(
                      "pages.companies.projects.form.client_id_placeholder"
                    )}
                  />
                </SelectTrigger>
                <SelectContent>
                  {clients.map(({ id, name }) => (
                    <SelectItem key={id} value={id.toString()}>
                      {name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />
    </>
  );
};

export { BasicInfoStep };
