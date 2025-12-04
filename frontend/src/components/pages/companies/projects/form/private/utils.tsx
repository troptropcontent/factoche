import { z } from "zod";
import { v4 as uuidv4 } from "uuid";
import { formSchema, step2FormSchema } from "../project-form.schema";
import { CSV_FIELDS, DEFAULT_TAX_RATE } from "./constants";
import { useTranslation } from "react-i18next";
import { ProjectExtended, UpdateProjectBody } from "../../shared/types";

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

const newDiscountInput = (
  position: number
): z.infer<typeof step2FormSchema>["discounts"][number] => {
  return {
    name: "",
    description: "",
    position: position,
    kind: "fixed_amount",
    value: 0,
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

const computeGrossTotal = (
  items: Array<{ quantity: number; unit_price_amount: number }>
) => {
  return items.reduce((total, current) => {
    return total + current.quantity * current.unit_price_amount;
  }, 0);
};

const computeNetTotal = (
  items: Array<{ quantity: number; unit_price_amount: number }>,
  discounts: Array<{
    position: number;
    kind: "fixed_amount" | "percentage";
    value: number;
  }>
) => {
  const grossTotal = computeGrossTotal(items);
  return discounts.reduce((netTotal, discount) => {
    const discountAmount =
      discount.kind === "fixed_amount"
        ? discount.value
        : netTotal * (discount.value / 100);
    return netTotal - discountAmount;
  }, grossTotal);
};

const computeDiscountAmounts = (
  grossTotal: number,
  discounts: Array<{
    position: number;
    kind: "fixed_amount" | "percentage";
    value: number;
  }>
) => {
  let remainingTotal = grossTotal;
  return discounts.reduce<Record<string, number>>(
    (discountAmounts, discount) => {
      const discountAmount =
        discount.kind === "fixed_amount"
          ? discount.value
          : remainingTotal * (discount.value / 100);
      remainingTotal = Math.min(remainingTotal - discountAmount, 0);
      discountAmounts[discount.position] = discountAmount;
      return discountAmounts;
    },
    {}
  );
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

const groupAccordionItemValue = (group: { uuid: string }) =>
  `item-group-${group.uuid}`;

const buildProjectFormInitialValue = (
  project: ProjectExtended
): z.infer<typeof formSchema> => {
  const groupsWithUuid = project.last_version.item_groups.map((group) => ({
    ...group,
    description: group.description || "",
    uuid: uuidv4(),
  }));
  return {
    name: project.name,
    description: project.description || "",
    client_id: project.client.id,
    bank_detail_id: project.bank_detail.id,
    address_city: project.address_city || "",
    address_street: project.address_street || "",
    address_zipcode: project.address_zipcode || "",
    po_number: project.po_number || "",
    retention_guarantee_rate:
      Number(project.last_version.retention_guarantee_rate) * 100,
    items: project.last_version.items.map((item) => ({
      ...item,
      uuid: uuidv4(),
      original_item_uuid: item.original_item_uuid,
      unit_price_amount: Number(item.unit_price_amount),
      tax_rate: Number(item.tax_rate) * 100,
      description: item.description || "",
      group_uuid: groupsWithUuid.find(
        (group) => group.id === item.item_group_id
      )?.uuid,
    })),
    groups: groupsWithUuid,
    discounts: project.last_version.discounts.map((discount) => {
      return {
        ...discount,
        value:
          discount.kind === "percentage"
            ? Number(discount.value) * 100
            : Number(discount.value),
        description: "",
      };
    }),
  };
};

const buildUpdateProjectBody = (
  inputs: z.infer<typeof formSchema>
): UpdateProjectBody => {
  const buildUpdatedItemInput = (items: (typeof inputs)["items"]) => {
    return items
      .filter((item) => item.original_item_uuid != undefined)
      .map((updated_item) => ({
        position: updated_item.position,
        quantity: updated_item.quantity,
        tax_rate: updated_item.tax_rate / 100,
        unit_price_amount: updated_item.unit_price_amount,
        group_uuid: updated_item.group_uuid,
        original_item_uuid: updated_item.original_item_uuid!,
      }));
  };

  const buildNewItemInput = (items: (typeof inputs)["items"]) => {
    return items
      .filter((item) => item.original_item_uuid === undefined)
      .map((new_item) => ({
        name: new_item.name,
        unit: new_item.unit,
        position: new_item.position,
        quantity: new_item.quantity,
        tax_rate: new_item.tax_rate / 100,
        unit_price_amount: new_item.unit_price_amount,
        group_uuid: new_item.group_uuid,
        ...(new_item.description != "" && new_item.description != undefined
          ? { description: new_item.description }
          : {}),
      }));
  };

  const buildUpdatedDiscountInput = (
    discounts: (typeof inputs)["discounts"]
  ) => {
    return discounts
      .filter((discount) => discount.original_discount_uuid != undefined)
      .map((updated_discount) => ({
        original_discount_uuid: updated_discount.original_discount_uuid!,
        position: updated_discount.position + 1,
        kind: updated_discount.kind,
        value:
          updated_discount.kind === "percentage"
            ? updated_discount.value / 100
            : updated_discount.value,
      }));
  };

  const buildNewDiscountInput = (discounts: (typeof inputs)["discounts"]) => {
    return discounts
      .filter((discount) => discount.original_discount_uuid == undefined)
      .map((new_discount) => ({
        position: new_discount.position + 1,
        name: new_discount.name,
        value:
          new_discount.kind === "percentage"
            ? new_discount.value / 100
            : new_discount.value,
        kind: new_discount.kind,
      }));
  };

  const buildGroupsInput = (
    groups: (typeof inputs)["groups"]
  ): UpdateProjectBody["groups"] => {
    return groups.map((group) => ({
      name: group.name,
      position: group.position,
      uuid: group.uuid,
      ...(group.description != "" && group.description != undefined
        ? { description: group.description }
        : {}),
    }));
  };

  return {
    name: inputs.name,
    description: inputs.description,
    po_number: inputs.po_number,
    retention_guarantee_rate: Number(inputs.retention_guarantee_rate) / 100,
    bank_detail_id: inputs.bank_detail_id,
    updated_items: buildUpdatedItemInput(inputs.items),
    new_items: buildNewItemInput(inputs.items),
    new_discounts: buildNewDiscountInput(inputs.discounts),
    updated_discounts: buildUpdatedDiscountInput(inputs.discounts),
    groups: buildGroupsInput(inputs.groups),
  };
};

const computeTotalDiscountsAndTaxes = (
  inputs: z.infer<typeof step2FormSchema>
): {
  totalWithoutTax: number;
  discount: number;
  taxes: { rate: number; value: number }[];
} => {
  // 1. Calculate total without tax (subtotal of all items)
  const totalWithoutTax = inputs.items.reduce((total, item) => {
    return total + item.quantity * item.unit_price_amount;
  }, 0);

  // 2. Calculate total discount amount
  const totalAfterDiscount = inputs.discounts.reduce(
    (subtotalSubjectToDiscount, discount) => {
      if (discount.kind === "fixed_amount") {
        subtotalSubjectToDiscount = subtotalSubjectToDiscount - discount.value;
      } else {
        subtotalSubjectToDiscount =
          subtotalSubjectToDiscount -
          (subtotalSubjectToDiscount * discount.value) / 100;
      }
      return subtotalSubjectToDiscount;
    },
    totalWithoutTax
  );

  // 3. Group items by tax rate and calculate tax for each rate
  const taxesByRate = new Map<number, number>();

  inputs.items.forEach((item) => {
    const itemTotal = item.quantity * item.unit_price_amount;
    // Apply proportional discount to this item
    const itemAfterDiscount =
      itemTotal * (totalAfterDiscount / totalWithoutTax);
    const taxAmount = (itemAfterDiscount * item.tax_rate) / 100;

    const currentTax = taxesByRate.get(item.tax_rate) || 0;
    taxesByRate.set(item.tax_rate, currentTax + taxAmount);
  });

  // Convert to array format
  const taxes = Array.from(taxesByRate.entries())
    .map(([rate, value]) => ({ rate, value }))
    .sort((a, b) => a.rate - b.rate);

  return {
    totalWithoutTax: totalWithoutTax,
    discount: totalWithoutTax - totalAfterDiscount,
    taxes,
  };
};

const computeDiscountValue = (
  inputs: z.infer<typeof step2FormSchema>,
  discountInputIndex: number
): number => {
  const totalWithoutTaxes = computeTotal(inputs.items);
  let totalSubjectedToDiscount = totalWithoutTaxes;
  let discountValue = 0;
  for (let index = 0; index <= discountInputIndex; index++) {
    const discount = inputs.discounts[discountInputIndex];
    discountValue =
      discount!.kind === "fixed_amount"
        ? discount!.value
        : totalSubjectedToDiscount * (discount!.value / 100);
    totalSubjectedToDiscount = totalSubjectedToDiscount - discountValue;
  }

  return discountValue;
};

export {
  computeDiscountAmounts,
  computeNetTotal,
  computeGrossTotal,
  computeDiscountValue,
  computeTotalDiscountsAndTaxes,
  newDiscountInput,
  newGroupInput,
  newItemInput,
  findNextPosition,
  computeTotal,
  buildCsvTemplateData,
  buildProjectFormInitialValue,
  buildUpdateProjectBody,
  groupAccordionItemValue,
};
