import { Layout } from "@/components/pages/companies/layout";
import { useTranslation } from "react-i18next";
import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { ProjectForm } from "@/components/pages/companies/projects/form/project-form";
import { PROJECT_FORM_INITIAL_VALUES } from "@/components/pages/companies/projects/form/private/constants";
import { useToast } from "@/hooks/use-toast";
import { Api } from "@/lib/openapi-fetch-query-client";
import { z } from "zod";
import { formSchema } from "@/components/pages/companies/projects/form/project-form.schema";

export const Route = createFileRoute(
  "/_authenticated/companies/$companyId/quotes/new"
)({
  component: RouteComponent,
});

function RouteComponent() {
  const { t } = useTranslation();
  const { companyId } = Route.useParams();
  const { mutateAsync } = Api.useMutation(
    "post",
    "/api/v1/organization/companies/{company_id}/clients/{client_id}/quotes"
  );
  const { toast } = useToast();
  const navigate = useNavigate();
  const createNewProject = async (data: z.infer<typeof formSchema>) => {
    await mutateAsync(
      {
        body: {
          ...data,
          retention_guarantee_rate: data.retention_guarantee_rate / 100,
          items: data.items.map((input) => ({
            ...input,
            tax_rate: input.tax_rate / 100,
          })),
        },
        params: {
          path: { company_id: Number(companyId), client_id: data.client_id },
        },
      },
      {
        onSuccess: ({ result: { id } }) => {
          toast({
            variant: "success",
            title: t(
              "pages.companies.projects.form.confirmation_step.toast.success_toast_title"
            ),
            description: t(
              "pages.companies.projects.form.confirmation_step.toast.success_toast_description"
            ),
          });
          navigate({
            to: "/companies/$companyId/quotes/$quoteId",
            params: { companyId: companyId, quoteId: id.toString() },
          });
        },
        onError: () => {
          toast({
            variant: "destructive",
            title: t(
              "pages.companies.projects.form.confirmation_step.toast.error_toast_title"
            ),
            description: t(
              "pages.companies.projects.form.confirmation_step.toast.error_toast_description"
            ),
          });
        },
      }
    );
  };

  return (
    <Layout.Root>
      <Layout.Header>
        <h1 className="text-3xl font-bold">
          {t("pages.companies.quotes.new.title")}
        </h1>
      </Layout.Header>
      <Layout.Content>
        <ProjectForm
          companyId={companyId}
          initialValues={PROJECT_FORM_INITIAL_VALUES}
          submitFunction={createNewProject}
        />
      </Layout.Content>
    </Layout.Root>
  );
}
