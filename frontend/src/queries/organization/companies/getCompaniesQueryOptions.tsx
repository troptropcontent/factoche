import { api } from "@/services/api";
import { queryOptions } from "@tanstack/react-query";

const getCompaniesQueryOptions = () =>
  queryOptions({
    queryKey: ["organization", "companies"],
    queryFn: api.organization.companies.index,
  });

export { getCompaniesQueryOptions };
