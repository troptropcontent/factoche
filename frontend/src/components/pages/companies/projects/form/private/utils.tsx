import { z } from "zod";
import { v4 as uuidv4 } from "uuid";
import { step2FormSchema } from "../project-form.schema";
import { CSV_FIELDS, DEFAULT_TAX_RATE } from "./constants";
import { useTranslation } from "react-i18next";

const newGroupInput = (
  position: number
): z.infer<typeof step2FormSchema>["groups"][number] => {
  return {
    uuid: uuidv4(),
    name: "",
    description: "",
    position: position,
  };
};

const newItemInput = (
  position: number,
  groupUuid: string | null = null
): z.infer<typeof step2FormSchema>["items"][number] => {
  const baseItem = {
    uuid: uuidv4(),
    position,
    name: "",
    description: "",
    quantity: 0,
    unit_price_amount: 0,
    unit: "",
    tax_rate: DEFAULT_TAX_RATE,
  };

  return groupUuid ? { ...baseItem, group_uuid: groupUuid } : baseItem;
};

const findNextPosition = (
  ...positionnedArrays: Array<{ position: number }[]>
): number => {
  const positions = positionnedArrays.flatMap((positionnedArray) =>
    positionnedArray.map((e) => e.position)
  );
  return Math.max(...positions, -1) + 1;
};

const computeTotal = (
  items: Array<{ quantity: number; unit_price_amount: number }>
) => {
  return items.reduce((total, current) => {
    return total + current.quantity * current.unit_price_amount;
  }, 0);
};

const buildCsvTemplateData = (
  t: ReturnType<typeof useTranslation>["t"],
  reverseMapping: Record<keyof typeof CSV_FIELDS, string>
) => {
  const headers = Object.values(reverseMapping).join(",");
  const buildLine = (lineNumber: number) => {
    return Object.keys(reverseMapping)
      .map((key) => {
        const value = t(
          `pages.companies.projects.form.composition_step.import_csv_modal.tabs.upload.template.line${lineNumber}.${key}`,
          { defaultValue: "not_found" }
        );
        if (value === "not_found") {
          throw new Error(
            `Translation not found for field ${key} line ${lineNumber}`
          );
        }
        return value;
      })
      .join(",");
  };
  const line1 = buildLine(1);
  const line2 = buildLine(2);
  return `${headers}
${line1}
${line2}`;
};

export {
  newGroupInput,
  newItemInput,
  findNextPosition,
  computeTotal,
  buildCsvTemplateData,
};
