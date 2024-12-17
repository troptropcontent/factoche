import { getCompanies } from "@/services/api/organization/companies";

const api = {
  organization: {
    companies: {
      index: getCompanies,
    },
  },
};

export { api };
