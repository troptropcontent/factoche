import { Api } from "@/services/api/client";
import { queryOptions } from "@tanstack/react-query";

const getCompaniesQueryOptions = () =>
  queryOptions({
    queryKey: ["organization", "companies"],
    queryFn: async () => Api.GET("/api/v1/organization/companies", null),
  });

export { getCompaniesQueryOptions };
