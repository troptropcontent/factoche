import { api } from "@/services/api";
import { queryOptions } from "@tanstack/react-query";

const getCompanyQueryOptions = (companyId: string) =>
  queryOptions({
    queryKey: ["organization", "companies", companyId],
    queryFn: () => api.organization.companies.show(companyId),
  });

export { getCompanyQueryOptions };
