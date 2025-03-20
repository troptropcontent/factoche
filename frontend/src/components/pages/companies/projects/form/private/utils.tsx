import { z } from "zod";
import { v4 as uuidv4 } from "uuid";
import { step2FormSchema } from "../project-form.schema";
import { DEFAULT_TAX_RATE } from "./constants";

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

export { newGroupInput, newItemInput, findNextPosition, computeTotal };
