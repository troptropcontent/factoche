import { Api } from "@/services/api/client";
import { queryOptions } from "@tanstack/react-query";

const getCompanyClientsQueryOptions = (companyId: string) =>
  queryOptions({
    queryKey: ["organization", "companies", companyId, "clients"],
    queryFn: async () =>
      Api.GET("/api/v1/organization/companies/{company_id}/clients", {
        path: { company_id: parseInt(companyId) },
      }).then((response) => response.data),
  });

export { getCompanyClientsQueryOptions };
