import { Api } from "@/services/api/client";

const Path = "/api/v1/organization/companies/{company_id}/clients" as const;
type ApiVariables = Parameters<typeof Api.POST<typeof Path>>[1]["body"];

const createClientMutationOptions = (company_id: number) => ({
  mutationFn: (variables: ApiVariables) =>
    Api.POST(Path, {
      path: { company_id },
      body: variables,
    }),
});

export { createClientMutationOptions };
