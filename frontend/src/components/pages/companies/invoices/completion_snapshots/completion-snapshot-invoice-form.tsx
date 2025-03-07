import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { completionSnapshotInvoiceFormSchema } from "./private/schemas";
import { z } from "zod";
import { FormProjectSummary } from "./private/form-project-summary";
import { Form } from "@/components/ui/form";
import { FormItemGroup } from "./private/form-item-group";
import { FormSubmitButton } from "./private/form-submit-button";
import { FormInvoiceTotalInfo } from "./private/form-invoice-total-info";

interface CompletionSnapshotInvoiceFormProps {
  companyId: number;
  projectId: number;
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
  itemGroups,
  items,
}: CompletionSnapshotInvoiceFormProps) => {
  const initialValues = items.map((item) => ({
    original_item_uuid: item.original_item_uuid,
    invoice_amount: 0,
  }));
  const form = useForm<z.infer<typeof completionSnapshotInvoiceFormSchema>>({
    resolver: zodResolver(completionSnapshotInvoiceFormSchema),
    defaultValues: { invoiced_amounts: initialValues },
  });

  const onSubmit = (
    data: z.infer<typeof completionSnapshotInvoiceFormSchema>
  ) => {
    console.log({ data });
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
