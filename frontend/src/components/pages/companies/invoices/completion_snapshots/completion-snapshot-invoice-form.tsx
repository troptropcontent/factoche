import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { completionSnapshotInvoiceFormSchema } from "./private/schemas";
import { z } from "zod";
import { FormProjectSummary } from "./private/form-project-summary";
import { Form } from "@/components/ui/form";
import { FormItemGroup } from "./private/form-item-group";
import { FormSubmitButton } from "./private/form-submit-button";
import { FormInvoiceTotalInfo } from "./private/form-invoice-total-info";
import { Api } from "@/lib/openapi-fetch-query-client";
import { useNavigate } from "@tanstack/react-router";
import { useToast } from "@/hooks/use-toast";
import { useTranslation } from "react-i18next";

interface CompletionSnapshotInvoiceFormProps {
  companyId: number;
  projectId: number;
  projectVersionId: number;
  items: Array<{
    id: number;
    original_item_uuid: string;
    name: string;
    quantity: number;
    unit_price_cents: number;
    unit: string;
    item_group_id?: number | null;
  }>;
  itemGroups: Array<{
    id: number;
    name: string;
    description?: string | null;
  }>;
  previouslyInvoicedAmountsPerItems: Record<string, number>;
  projectTotal: number;
}

const CompletionSnapshotInvoiceForm = ({
  companyId,
  projectId,
  projectVersionId,
  itemGroups,
  items,
}: CompletionSnapshotInvoiceFormProps) => {
  const initialValues = items.map((item) => ({
    original_item_uuid: item.original_item_uuid,
    invoice_amount: 0,
  }));
  const form = useForm<z.infer<typeof completionSnapshotInvoiceFormSchema>>({
    resolver: zodResolver(completionSnapshotInvoiceFormSchema),
    defaultValues: { invoice_amounts: initialValues },
  });
  const { mutate: createNewInvoice } = Api.useMutation(
    "post",
    "/api/v1/organization/project_versions/{project_version_id}/invoices/completion_snapshot"
  );
  const navigate = useNavigate();
  const { toast } = useToast();
  const { t } = useTranslation();

  const onSubmit = (
    data: z.infer<typeof completionSnapshotInvoiceFormSchema>
  ) => {
    createNewInvoice(
      {
        params: { path: { project_version_id: projectVersionId } },
        body: {
          invoice_amounts: data.invoice_amounts.map((invoice_amount) => ({
            ...invoice_amount,
            invoice_amount: invoice_amount.invoice_amount.toString(),
          })),
        },
      },
      {
        onSuccess() {
          toast({
            title: t(
              "pages.companies.projects.invoices.completion_snapshot.form.toast.create_success_toast_title"
            ),
          });
          navigate({
            to: "/companies/$companyId/projects/$projectId",
            params: {
              companyId: companyId.toString(),
              projectId: projectId.toString(),
            },
          });
        },
      }
    );
  };

  return (
    <Form {...form}>
      <form
        onSubmit={form.handleSubmit(onSubmit)}
        className="flex flex-col flex-grow gap-4"
      >
        <FormProjectSummary companyId={companyId} projectId={projectId} />
        {itemGroups.map((itemGroup) => (
          <FormItemGroup
            group={itemGroup}
            items={items.filter(
              ({ item_group_id }) => item_group_id === itemGroup.id
            )}
            key={itemGroup.id}
            projectId={projectId}
          />
        ))}
        <div className="flex justify-between">
          <FormInvoiceTotalInfo />
          <FormSubmitButton />
        </div>
      </form>
    </Form>
  );
};

export { CompletionSnapshotInvoiceForm };
