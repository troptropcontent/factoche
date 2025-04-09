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
  "/_authenticated/companies/$companyId/orders/$orderId/update"
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
  const { companyId, orderId } = Route.useParams();
  const { data: order } = Api.useQuery(
    "get",
    "/api/v1/organization/orders/{id}",
    { params: { path: { id: Number(orderId) } } },
    { select: ({ result }) => result }
  );
  const { mutateAsync } = Api.useMutation(
    "put",
    "/api/v1/organization/orders/{id}"
  );
  const { toast } = useToast();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const updateOrderAsync = async (data: z.infer<typeof formSchema>) => {
    await mutateAsync(
      {
        body: buildUpdateProjectBody(data),
        params: {
          path: { id: Number(orderId) },
        },
      },
      {
        onSuccess: (data) => {
          toast({
            variant: "success",
            title: t("pages.companies.orders.update.toasts.success.title"),
            description: t(
              "pages.companies.orders.update.toasts.success.description"
            ),
          });
          queryClient.setQueryData(
            Api.queryOptions("get", "/api/v1/organization/orders/{id}", {
              params: { path: { id: data.result.id } },
            }).queryKey,
            data
          );
          navigate({
            to: "/companies/$companyId/orders/$orderId",
            params: {
              companyId: companyId,
              orderId: data.result.id.toString(),
            },
          });
        },

        onError: () => {
          toast({
            variant: "destructive",
            title: t("pages.companies.orders.update.toasts.error.title"),
            description: t(
              "pages.companies.orders.update.toasts.error.description"
            ),
          });
        },
      }
    );
  };

  return order === undefined ? (
    <LoadingLayout />
  ) : (
    <Layout.Root>
      <Layout.Header>
        <h1 className="text-3xl font-bold">
          {t("pages.companies.quotes.update.title", {
            number: order.number,
          })}
        </h1>
      </Layout.Header>
      <Layout.Content>
        <ProjectForm
          companyId={companyId}
          initialValues={buildProjectFormInitialValue(order)}
          submitFunction={updateOrderAsync}
        />
      </Layout.Content>
    </Layout.Root>
  );
}
