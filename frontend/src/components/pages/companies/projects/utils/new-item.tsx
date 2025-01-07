import { ProjectItemType } from "../project-form";

const newItem = (position: number): ProjectItemType => {
  return {
    name: "",
    quantity: 0,
    unit_price: 0,
    description: "",
    unit: "",
    position: position,
  };
};

export { newItem };
