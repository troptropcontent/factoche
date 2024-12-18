import {
  getCompanies,
  getCompany,
} from "@/services/api/organization/companies";

const api = {
  organization: {
    companies: {
      index: getCompanies,
      show: getCompany,
    },
  },
};

export { api };
