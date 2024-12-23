import { Api } from "@/services/api/client";
import { queryOptions } from "@tanstack/react-query";

const getCompanyQueryOptions = (companyId: string) =>
  queryOptions({
    queryKey: ["organization", "companies", companyId],
    queryFn: async () =>
      Api.GET("/api/v1/organization/companies/{id}", {
        path: { id: parseInt(companyId) },
      }),
  });

export { getCompanyQueryOptions };
