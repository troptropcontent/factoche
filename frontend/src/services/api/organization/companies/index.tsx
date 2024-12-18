import { CompanyType } from "./types";
import apiClient from "@/lib/api-client";

export const getCompanies = async () => {
  return apiClient
    .get<Array<CompanyType>>("/api/v1/organization/companies")
    .then((r) => r.data);
};

export const getCompany = async (id: string) => {
  return apiClient
    .get<CompanyType>(`/api/v1/organization/companies/${id}`)
    .then((r) => r.data);
};
