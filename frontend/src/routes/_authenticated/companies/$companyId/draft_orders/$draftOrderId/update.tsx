import { Layout } from "@/components/pages/companies/layout";
import {
  buildProjectFormInitialValue,
  buildUpdateProjectBody,
} from "@/components/pages/companies/projects/form/private/utils";
import { ProjectForm } from "@/components/pages/companies/projects/form/project-form";
import { Api } from "@/lib/openapi-fetch-query-client";
import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";

export const Route = createFileRoute(
  "/_authenticated/companies/$companyId/draft_orders/$draftOrderId/update"
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
  const { companyId, draftOrderId } = Route.useParams();
  const { data: draftOrder } = Api.useQuery(
    "get",
    "/api/v1/organization/draft_orders/{id}",
    { params: { path: { id: Number(draftOrderId) } } },
    { select: ({ result }) => result }
  );
  const { mutateAsync } = Api.useMutation(
    "put",
    "/api/v1/organization/draft_orders/{id}"
  );
  const { toast } = useToast();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const updateDraftOrderAsync = async (data: z.infer<typeof formSchema>) => {
    await mutateAsync(
      {
        body: buildUpdateProjectBody(data),
        params: {
          path: { id: Number(draftOrderId) },
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
            Api.queryOptions("get", "/api/v1/organization/draft_orders/{id}", {
              params: { path: { id: data.result.id } },
            }).queryKey,
            data
          );
          navigate({
            to: "/companies/$companyId/draft_orders/$draftOrderId",
            params: {
              companyId: companyId,
              draftOrderId: data.result.id.toString(),
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

  return draftOrder === undefined ? (
    <LoadingLayout />
  ) : (
    <Layout.Root>
      <Layout.Header>
        <h1 className="text-3xl font-bold">
          {t("pages.companies.draft_orders.update.title", {
            number: draftOrder.number,
          })}
        </h1>
      </Layout.Header>
      <Layout.Content>
        <ProjectForm
          update
          companyId={companyId}
          initialValues={buildProjectFormInitialValue(draftOrder)}
          submitFunction={updateDraftOrderAsync}
        />
      </Layout.Content>
    </Layout.Root>
  );
}
