const buildChartCardRevenueByClientData = (
  revenuData: { client_id: number; revenue: string }[],
  clientsData: { id: number; name: string }[]
) => {
  const findClientName = (id: number) => {
    const client = clientsData.find((client) => client.id === id);
    if (client === undefined) {
      throw `coulc not find a client with the id ${id}, this is likely a bug`;
    }
    return client.name;
  };

  return revenuData.map(({ client_id, revenue }) => ({
    name: findClientName(client_id),
    revenue: Number(revenue),
  }));
};

export { buildChartCardRevenueByClientData };
