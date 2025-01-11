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

const buildApiRequestBody = (
  multiStepFormData: z.infer<typeof step1FormSchema> &
    z.infer<typeof step2FormSchema>
) => {
  return {
    project: {
      name: multiStepFormData.name,
      description: multiStepFormData.description,
      project_version_attributes: {
        retention_guarantee_rate: multiStepFormData.retention_guarantee_rate,
        items_attributes: multiStepFormData.items
          .filter((item) => item.type === "item")
          // eslint-disable-next-line @typescript-eslint/no-unused-vars
          .map(({ type, ...item }) => item),
        item_groups_attributes: multiStepFormData.items
          .filter((item) => item.type === "group")
          // eslint-disable-next-line @typescript-eslint/no-unused-vars
          .map(({ type, items, ...group }) => ({
            ...group,
            items_attributes: items.map((item) => item),
          })),
      },
    },
  };
};

export {
  newItem,
  newItemGroup,
  findNextPosition,
  computeItemsTotal,
  buildApiRequestBody,
};
