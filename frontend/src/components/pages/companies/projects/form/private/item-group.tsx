import { useFieldArray } from "react-hook-form";

import { useFormContext } from "react-hook-form";
import { Item } from "./item";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { useTranslation } from "react-i18next";
import { FormField, FormMessage } from "@/components/ui/form";
import { FormControl } from "@/components/ui/form";
import { FormItem } from "@/components/ui/form";
import { step2FormSchema } from "../project-form.schema";
import { z } from "zod";
import { CornerLeftUp, CornerRightUp, Trash } from "lucide-react";
import { groupAccordionItemValue, newItemInput } from "./utils";
import { findNextPosition } from "../project-form.utils";
import {
  Card,
  CardContent,
  CardFooter,
  CardHeader,
} from "@/components/ui/card";
import {
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";

const ItemGroup = ({ uuid, remove }: { uuid: string; remove: () => void }) => {
  const { t } = useTranslation();
  const { control, formState, watch } =
    useFormContext<z.infer<typeof step2FormSchema>>();

  const { append: appendItemInputs } = useFieldArray({
    control: control,
    name: "items",
  });

  const watchedItemInputs = watch("items");

  const { fields: groupInputs } = useFieldArray({
    control: control,
    name: "groups",
  });

  const groupInputIndex = groupInputs.findIndex(
    (groupInput) => groupInput.uuid == uuid
  );

  const addNewItemInput = () => {
    const nextPosition = findNextPosition(watchedItemInputs);
    appendItemInputs(newItemInput(nextPosition, uuid));
  };

  const positionnedItems = watchedItemInputs
    .filter((itemInput) => itemInput.group_uuid === uuid)
    .sort((a, b) => a.position - b.position);

  const groupTotal = positionnedItems.reduce(
    (memo, positionnedItem) =>
      memo + positionnedItem.quantity * positionnedItem.unit_price_amount,
    0
  );

  return (
    <AccordionItem value={groupAccordionItemValue({ uuid })}>
      <Card className="mb-4 last:mb-0">
        <CardHeader className="flex flex-row items-center gap-4 bg-muted">
          <FormField
            control={control}
            name={`groups.${groupInputIndex}.name`}
            render={({ field }) => (
              <FormItem className="flex-grow">
                <FormControl>
                  <Input
                    placeholder={t(
                      "pages.companies.projects.form.composition_step.item_group_name_input_description"
                    )}
                    className="bg-white"
                    {...field}
                  />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />
          <p>
            {t(
              "pages.companies.projects.form.composition_step.item_group_total"
            )}
            {" : "}
            {t("common.number_in_currency", {
              amount: groupTotal,
            })}
          </p>
          <Button variant="outline" type="button" onClick={remove}>
            <Trash />
          </Button>
          <AccordionTrigger />
        </CardHeader>
        <AccordionContent className="pb-0">
          <CardContent className="flex p-0">
            <div className="p-6 flex-grow">
              {positionnedItems.map((item) => (
                <Item inputId={item.uuid} key={item.uuid} />
              ))}
              {positionnedItems.length === 0 && formState.isSubmitted && (
                <FormMessage className="mb-4">
                  {t(
                    "pages.companies.projects.form.composition_step.no_items_in_group_error"
                  )}
                </FormMessage>
              )}
            </div>
          </CardContent>
          <CardFooter className="flex gap-6">
            <Button
              variant="outline"
              type="button"
              onClick={addNewItemInput}
              className="border-dashed flex-grow flex gap-2 justify-center"
              title="Prout"
            >
              <CornerLeftUp />
              {t(
                "pages.companies.projects.form.item_group_add_item_button_label"
              )}
              <CornerRightUp />
            </Button>
          </CardFooter>
        </AccordionContent>
      </Card>
    </AccordionItem>
  );
};

export { ItemGroup };
