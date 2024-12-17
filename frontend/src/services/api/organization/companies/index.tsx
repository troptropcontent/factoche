import { CompanyType } from "./types";
import apiClient from "@/lib/api-client";

export const getCompanies = async () => {
  return apiClient
    .get<Array<CompanyType>>("/api/v1/organization/companies")
    .then((r) => r.data);
};
