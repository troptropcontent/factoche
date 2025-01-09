const newItemGroup = (position: number) => {
  return {
    name: "",
    description: "",
    position: position,
    type: "group" as const,
    items: [],
  };
};

export { newItemGroup };
