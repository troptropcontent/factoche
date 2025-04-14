import { Layout } from "@/components/pages/companies/layout";
import {
  buildProjectFormInitialValue,
  buildUpdateProjectBody,
} from "@/components/pages/companies/projects/form/private/utils";
import { ProjectForm } from "@/components/pages/companies/projects/form/project-form";
import { LoadingWrapper } from "@/components/ui/loading-wrapper";
import { Api } from "@/lib/openapi-fetch-query-client";
import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";

export const Route = createFileRoute(
  "/_authenticated/companies/$companyId/quotes/$quoteId/update"
)({
  component: RouteComponent,
});

import { Skeleton } from "@/components/ui/skeleton";
import { useToast } from "@/hooks/use-toast";
import { formSchema } from "@/components/pages/companies/projects/form/project-form.schema";
import { z } from "zod";
import { useQueryClient } from "@tanstack/react-query";

const LoadingLayout = () => {
  return (
    <Layout.Root>
      <Layout.Header>
        <Skeleton className="h-8 w-1/2" />
      </Layout.Header>
      <Layout.Content>
        <Skeleton className="h-4 w-full mb-2" />
        <Skeleton className="h-4 w-full mb-2" />
        <Skeleton className="h-4 w-full mb-2" />
      </Layout.Content>
    </Layout.Root>
  );
};

function RouteComponent() {
  const { t } = useTranslation();
  const { companyId, quoteId } = Route.useParams();
  const { data: quote } = Api.useQuery(
    "get",
    "/api/v1/organization/quotes/{id}",
    { params: { path: { id: Number(quoteId) } } },
    { select: ({ result }) => result }
  );
  const { mutateAsync } = Api.useMutation(
    "put",
    "/api/v1/organization/quotes/{id}"
  );
  const { toast } = useToast();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const updateQuoteAsync = async (data: z.infer<typeof formSchema>) => {
    await mutateAsync(
      {
        body: buildUpdateProjectBody(data),
        params: {
          path: { id: Number(quoteId) },
        },
      },
      {
        onSuccess: (data) => {
          toast({
            variant: "success",
            title: t(
              "pages.companies.projects.form.confirmation_step.toast.success_toast_title"
            ),
            description: t(
              "pages.companies.projects.form.confirmation_step.toast.success_toast_description"
            ),
          });
          queryClient.setQueryData(
            Api.queryOptions("get", "/api/v1/organization/quotes/{id}", {
              params: { path: { id: data.result.id } },
            }).queryKey,
            data
          );
          navigate({
            to: "/companies/$companyId/quotes/$quoteId",
            params: {
              companyId: companyId,
              quoteId: data.result.id.toString(),
            },
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

  return quote === undefined ? (
    <LoadingLayout />
  ) : (
    <Layout.Root>
      <Layout.Header>
        <LoadingWrapper isLoading={quote == undefined}>
          <h1 className="text-3xl font-bold">
            {t("pages.companies.quotes.update.title", {
              number: quote?.number,
            })}
          </h1>
        </LoadingWrapper>
      </Layout.Header>
      <Layout.Content>
        <LoadingWrapper isLoading={quote === undefined}>
          <ProjectForm
            update
            companyId={companyId}
            initialValues={buildProjectFormInitialValue(quote)}
            submitFunction={updateQuoteAsync}
          />
        </LoadingWrapper>
      </Layout.Content>
    </Layout.Root>
  );
}
