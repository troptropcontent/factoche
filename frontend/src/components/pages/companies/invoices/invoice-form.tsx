import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { FormProjectSummary } from "./private/form-project-summary";
import { Form } from "@/components/ui/form";
import { FormItemGroup } from "./private/form-item-group";
import { FormSubmitButton } from "./private/form-submit-button";
import { Api } from "@/lib/openapi-fetch-query-client";
import { useNavigate } from "@tanstack/react-router";
import { useToast } from "@/hooks/use-toast";
import { useTranslation } from "react-i18next";
import { useQueryClient } from "@tanstack/react-query";
import { useEffect, useMemo } from "react";
import { invoiceFormSchema } from "./private/schemas";
import { FormInvoiceTotalInfo } from "./private/form-invoice-total-info";

interface InvoiceFormProps {
  companyId: number;
  orderId: number;
  invoiceId?: number;
  items: Array<{
    id: number;
    original_item_uuid: string;
    name: string;
    quantity: number;
    unit_price_amount: number;
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
  initialValues?: z.infer<typeof invoiceFormSchema>;
}

const InvoiceForm = ({
  companyId,
  orderId,
  itemGroups,
  items,
  initialValues,
  invoiceId,
}: InvoiceFormProps) => {
  const formInitialValues = useMemo(
    () =>
      initialValues || {
        invoice_amounts: items.map((item) => ({
          original_item_uuid: item.original_item_uuid,
          invoice_amount: 0,
        })),
      },
    [initialValues, items]
  );

  const form = useForm<z.infer<typeof invoiceFormSchema>>({
    resolver: zodResolver(invoiceFormSchema),
    defaultValues: formInitialValues,
  });

  useEffect(() => {
    form.reset(formInitialValues);
  }, [formInitialValues, form]);

  const { mutateAsync: createNewInvoice } = Api.useMutation(
    "post",
    "/api/v1/organization/orders/{order_id}/invoices"
  );
  const { mutateAsync: updateNewInvoice } = Api.useMutation(
    "put",
    "/api/v1/organization/companies/{company_id}/invoices/{id}"
  );

  const queryClient = useQueryClient();

  const mutateFunction = async (data: z.infer<typeof invoiceFormSchema>) => {
    const body = {
      invoice_amounts: data.invoice_amounts.reduce<
        Array<{
          original_item_uuid: string;
          invoice_amount: string;
        }>
      >((prev, current) => {
        if (current.invoice_amount === 0) {
          return prev;
        }
        return [
          ...prev,
          {
            ...current,
            invoice_amount: current.invoice_amount.toString(),
          },
        ];
      }, []),
    };

    const onSuccess = () => {
      queryClient.refetchQueries(
        Api.queryOptions(
          "get",
          "/api/v1/organization/companies/{company_id}/invoices/{id}",
          {
            params: {
              path: { company_id: Number(companyId), id: Number(invoiceId) },
            },
          }
        )
      );

      toast({
        title: t(
          "pages.companies.projects.invoices.completion_snapshot.form.toast.create_success_toast_title"
        ),
      });
      navigate({
        to: "/companies/$companyId/orders/$orderId",
        params: {
          companyId: companyId.toString(),
          orderId: orderId.toString(),
        },
      });
    };

    const onError = () => {
      toast({
        variant: "destructive",
        title: t("common.toast.error_title"),
        description: t("common.toast.error_description"),
      });
    };

    const mutationOptions = { onError, onSuccess };

    if (invoiceId) {
      await updateNewInvoice(
        {
          params: { path: { company_id: companyId, id: invoiceId } },
          body,
        },
        mutationOptions
      );
    } else {
      await createNewInvoice(
        {
          params: { path: { order_id: orderId } },
          body,
        },
        mutationOptions
      );
    }
  };

  const navigate = useNavigate();
  const { toast } = useToast();
  const { t } = useTranslation();

  const onSubmit = async (data: z.infer<typeof invoiceFormSchema>) => {
    await mutateFunction(data);
  };

  return (
    <Form {...form}>
      <form
        onSubmit={form.handleSubmit(onSubmit)}
        className="flex flex-col flex-grow gap-4"
      >
        <FormProjectSummary orderId={orderId} />
        {itemGroups.map((itemGroup) => (
          <FormItemGroup
            group={itemGroup}
            items={items.filter(
              ({ item_group_id }) => item_group_id === itemGroup.id
            )}
            key={itemGroup.id}
            orderId={orderId}
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

export { InvoiceForm };
