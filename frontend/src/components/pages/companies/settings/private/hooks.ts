import { Api } from "@/lib/openapi-fetch-query-client";
import { SettingsForm } from "./types";

const useSettingsFormInitialValues = ({
  companyId,
}: {
  companyId: number;
}): SettingsForm => {
  const { data: company } = Api.useSuspenseQuery(
    "get",
    "/api/v1/organization/companies/{id}",
    { params: { path: { id: companyId } } },
    { select: ({ result }) => result }
  );

  return {
    name: company.name,
    registration_number: company.registration_number,
    email: company.email,
    phone: company.phone,
    address_city: company.address_city,
    address_street: company.address_street,
    address_zipcode: company.address_zipcode,
    legal_form: company.legal_form,
    rcs_city: company.rcs_city,
    rcs_number: company.rcs_number,
    vat_number: company.vat_number,
    capital_amount: company.capital_amount,
    configs: {
      general_terms_and_conditions: company.config.general_terms_and_conditions,
      default_vat_rate: Number(company.config.default_vat_rate) * 100,
      payment_term_days: company.config.payment_term_days,
      payment_term_accepted_methods: company.config
        .payment_term_accepted_methods as ("card" | "transfer" | "cash")[],
    },
  };
};

export { useSettingsFormInitialValues };
