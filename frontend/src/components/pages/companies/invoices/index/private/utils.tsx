import { ProjectVersionCompact } from "../../../project-versions/shared/types";
import { OrderCompact } from "../../../projects/shared/types";
import { InvoiceCompact } from "../../shared/types";

const findOrder = (
  invoice: InvoiceCompact,
  orderVersions: ProjectVersionCompact[],
  orders: OrderCompact[]
): OrderCompact | undefined => {
  const orderVersion = orderVersions.find(
    (orderVersion) => orderVersion.id === invoice.holder_id
  );
  if (orderVersion === undefined) {
    return undefined;
  }

  return orders.find((order) => order.id === orderVersion.project_id);
};

export { findOrder };
