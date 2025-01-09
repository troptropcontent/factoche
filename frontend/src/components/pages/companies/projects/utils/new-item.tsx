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

export { newItem };
