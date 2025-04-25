import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { Form } from "@/components/ui/form";
import { Api } from "@/lib/openapi-fetch-query-client";
import { useNavigate } from "@tanstack/react-router";
import { useToast } from "@/hooks/use-toast";
import { useTranslation } from "react-i18next";
import { useQueryClient } from "@tanstack/react-query";
import { useEffect, useMemo } from "react";
import { OrderExtended } from "../../orders/shared/types";
import {
  buildInitialValuesFromOrder,
  buildInitialValuesFromProforma,
} from "./utils";
import { proformaFormSchema } from "./proforma-form-schema";
import { ProformaFormProjectSummary } from "./proforma-form-project-summary";
import { ProformaFormInvoiceTotalInfo } from "./proforma-form-invoice-total-info";
import { ProformaFormSubmitButton } from "./proforma-form-submit-button";
import { ProformaFormItemGroup } from "./proforma-form-item-group";

interface ProformaFormProps {
  companyId: number;
  order: OrderExtended;
  proformaId?: number;
}

const ProformaForm = ({ companyId, order, proformaId }: ProformaFormProps) => {
  const { data: proforma } = Api.useQuery(
    "get",
    "/api/v1/organization/proformas/{id}",
    { params: { path: { id: Number(proformaId) } } },
    { select: ({ result }) => result, enabled: proformaId !== undefined }
  );

  const formInitialValues = useMemo(
    () =>
      proforma
        ? buildInitialValuesFromProforma(proforma)
        : buildInitialValuesFromOrder(order),
    [order, proforma]
  );

  const form = useForm<z.infer<typeof proformaFormSchema>>({
    resolver: zodResolver(proformaFormSchema),
    defaultValues: formInitialValues,
  });

  useEffect(() => {
    form.reset(formInitialValues);
  }, [formInitialValues, form]);

  const { mutateAsync: createNewProforma } = Api.useMutation(
    "post",
    "/api/v1/organization/orders/{order_id}/proformas"
  );

  const { mutateAsync: updateProforma } = Api.useMutation(
    "put",
    "/api/v1/organization/proformas/{id}"
  );

  const queryClient = useQueryClient();

  const mutateFunction = async (data: z.infer<typeof proformaFormSchema>) => {
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

    const onSuccess = ({ result: { id } }: { result: { id: number } }) => {
      if (proformaId !== undefined) {
        queryClient.refetchQueries(
          Api.queryOptions("get", "/api/v1/organization/proformas/{id}", {
            params: {
              path: { company_id: Number(companyId), id: Number(proformaId) },
            },
          })
        );
      }

      toast({
        title: t(
          "pages.companies.projects.invoices.completion_snapshot.form.toast.create_success_toast_title"
        ),
      });

      navigate({
        to: "/companies/$companyId/proformas/$proformaId",
        params: {
          companyId: companyId.toString(),
          proformaId: id.toString(),
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

    if (proformaId) {
      await updateProforma(
        {
          params: { path: { id: proformaId } },
          body,
        },
        mutationOptions
      );
    } else {
      await createNewProforma(
        {
          params: { path: { order_id: order.id } },
          body,
        },
        mutationOptions
      );
    }
  };

  const navigate = useNavigate();

  const { toast } = useToast();

  const { t } = useTranslation();

  const onSubmit = async (data: z.infer<typeof proformaFormSchema>) => {
    await mutateFunction(data);
  };

  return (
    <Form {...form}>
      <form
        onSubmit={form.handleSubmit(onSubmit)}
        className="flex flex-col flex-grow gap-4"
      >
        <ProformaFormProjectSummary orderId={order.id} />

        {order.last_version.item_groups.map((itemGroup) => (
          <ProformaFormItemGroup
            orderId={order.id}
            group={itemGroup}
            items={order.last_version.items.filter(
              ({ item_group_id }) => item_group_id === itemGroup.id
            )}
            key={itemGroup.id}
          />
        ))}
        <div className="flex justify-between">
          <ProformaFormInvoiceTotalInfo />
          <ProformaFormSubmitButton />
        </div>
      </form>
    </Form>
  );
};

export { ProformaForm };
