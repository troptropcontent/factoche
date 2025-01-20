import { z } from "zod";
import { step1FormSchema, step2FormSchema } from "./project-form.schema";

const newItemGroup = (position: number) => {
  return {
    name: "",
    description: "",
    position: position,
    type: "group" as const,
    items: [],
  };
};

const newItem = (position: number) => {
  return {
    name: "",
    description: "",
    position: position,
    type: "item" as const,
    quantity: 0,
    unit_price: 0,
    unit: "",
  };
};

const findNextPosition = (
  ...positionnedArrays: Array<{ position: number }[]>
): number => {
  const positions = positionnedArrays.flatMap((positionnedArray) =>
    positionnedArray.map((e) => e.position)
  );
  return Math.max(...positions, -1) + 1;
};

type SingleItem = { quantity: number; unit_price: number };
type ItemGroup = { items: SingleItem[] };

const computeItemsTotal = (items: Array<SingleItem | ItemGroup>) => {
  return items.reduce((total, current) => {
    if ("items" in current) {
      const groupTotal = current.items.reduce(
        (sum, item) => sum + item.quantity * item.unit_price,
        0
      );
      return total + groupTotal;
    }
    return total + current.quantity * current.unit_price;
  }, 0);
};

const buildApiRequestBody = ({
  name,
  client_id,
  items,
  retention_guarantee_rate,
  description,
}: z.infer<typeof step1FormSchema> & z.infer<typeof step2FormSchema>) => {
  const simpleItems = items
    .filter((item) => item.type == "item")
    .map(({ name, description, position, quantity, unit, unit_price }) => ({
      name,
      description,
      position,
      quantity,
      unit,
      unit_price_cents: Math.round(unit_price * 100),
    }));
  const groupItems = items
    .filter((item) => item.type == "group")
    .map(({ name, description, position, items }) => ({
      name,
      description,
      position,
      items: items.map(
        ({ name, description, position, quantity, unit, unit_price }) => ({
          name,
          description,
          position,
          quantity,
          unit,
          unit_price_cents: Math.round(unit_price * 100),
        })
      ),
    }));

  const mappedItems = simpleItems.length > 1 ? simpleItems : groupItems;

  return {
    name,
    description,
    retention_guarantee_rate: Math.round(retention_guarantee_rate * 100),
    client_id,
    items: mappedItems,
  };
};

export {
  newItem,
  newItemGroup,
  findNextPosition,
  computeItemsTotal,
  buildApiRequestBody,
};
