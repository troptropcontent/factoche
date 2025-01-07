import { ProjectItemGroupType } from "../project-form";

const newItemGroup = (position: number): ProjectItemGroupType => {
  return {
    name: "",
    description: "",
    position: position,
    items_attributes: [],
  };
};

export { newItemGroup };
