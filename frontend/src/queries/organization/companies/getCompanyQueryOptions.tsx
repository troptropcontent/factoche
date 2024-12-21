import { api } from "@/services/api";
import { client } from "@/services/api/client";
import { queryOptions } from "@tanstack/react-query";

const getCompanyQueryOptions = (companyId: string) =>
  queryOptions({
    queryKey: ["organization", "companies", companyId],
    queryFn: async () => {
      const { data, error } = await client.GET(
        "/api/v1/organization/companies/{id}",
        {
          params: { path: { id: parseInt(companyId) } },
        }
      );
      if (error) throw error;
      return data;
    },
  });

export { getCompanyQueryOptions };
