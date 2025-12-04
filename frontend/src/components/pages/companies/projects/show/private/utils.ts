import { ProjectVersionExtended } from "../../../project-versions/shared/types";

const computeDiscountAmounts = (projectVersion: ProjectVersionExtended) => {
  let remainingAmount = Number(projectVersion.total_excl_tax_amount);

  const sortedDiscounts = [...projectVersion.discounts].sort(
    (a, b) => a.position - b.position
  );

  return sortedDiscounts.reduce<Record<number, number>>((acc, discount) => {
    const discountValue = Number(discount.value);

    const discountAmount =
      discount.kind === "fixed_amount"
        ? Math.min(discountValue, remainingAmount)
        : remainingAmount * (discountValue / 100);

    acc[discount.id] = discountAmount;
    remainingAmount -= discountAmount;

    return acc;
  }, {});
};

export { computeDiscountAmounts };
