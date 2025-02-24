import { TableBody } from "@/components/ui/table";
import { TableHead, TableHeader, TableRow } from "@/components/ui/table";
import {
  Card,
  CardContent,
  CardDescription,
  CardTitle,
  CardHeader,
} from "@/components/ui/card";
import { Table } from "@/components/ui/table";
import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { useTranslation } from "react-i18next";
import { Form } from "@/components/ui/form";
import { buildInitialValues } from "./completion-snapshot-form.utils";
import { ItemRow } from "./item-row";
import { TotalInfo } from "./total-info";
import { Api } from "@/lib/openapi-fetch-query-client";
import { completionSnapshotFormSchema } from "./completion-snapshot-form.schemas";
import { useNavigate } from "@tanstack/react-router";
import { useToast } from "@/hooks/use-toast";
import { Check } from "lucide-react";
import { FormSubmitButton } from "./private/form-submit-button";
import { divideAllCompletionPercentagesByAHundred } from "./shared/utils";

type CompletionSnapshotFormType = {
  companyId: number;
  projectId: number;
  itemGroups: {
    id: number;
    name: string;
    description?: string | null;
    grouped_items: {
      id: number;
      name: string;
      description?: string | null;
      unit: string;
      unit_price_cents: number;
      quantity: number;
    }[];
  }[];
  previousCompletionSnapshot?: {
    id: number;
    description?: string | null;
    completion_snapshot_items: {
      item_id: number;
      completion_percentage: string;
    }[];
  };
  initialValues?: {
    description?: string | null;
    completion_snapshot_items: {
      item_id: number;
      completion_percentage: string;
    }[];
  };
  completionSnapshotId?: number;
};

const CompletionSnapshotForm = ({
  companyId,
  projectId,
  itemGroups,
  previousCompletionSnapshot,
  initialValues,
  completionSnapshotId,
}: CompletionSnapshotFormType) => {
  const { t } = useTranslation();
  const { mutate: createCompletionSnapshotMutation } = Api.useMutation(
    "post",
    "/api/v1/organization/companies/{company_id}/projects/{project_id}/completion_snapshots"
  );
  const { mutate: updateCompletionSnapshotMutation } = Api.useMutation(
    "put",
    "/api/v1/organization/completion_snapshots/{id}"
  );

  const form = useForm<z.infer<typeof completionSnapshotFormSchema>>({
    resolver: zodResolver(completionSnapshotFormSchema),
    defaultValues: initialValues
      ? {
          description: initialValues.description || "",
          completion_snapshot_items: initialValues.completion_snapshot_items,
        }
      : buildInitialValues({
          itemGroups,
          previousCompletionSnapshot,
        }),
  });

  const navigate = useNavigate();

  const { toast } = useToast();

  const triggerCreateMutationAndRedirectToProjectShow = (
    data: z.infer<typeof completionSnapshotFormSchema>
  ) => {
    const mappedData = divideAllCompletionPercentagesByAHundred(data);
    createCompletionSnapshotMutation(
      {
        params: { path: { company_id: companyId, project_id: projectId } },
        body: mappedData,
      },
      {
        onError: () => {
          toast({
            variant: "destructive",
            title: t("common.toast.error_title"),
            description: t("common.toast.error_description"),
          });
        },
        onSuccess: () => {
          toast({
            title: t(
              "pages.companies.completion_snapshot.form.success_toast_title"
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

  const triggerUpdateMutationAndRedirectToCompletionSnapshotShow = (
    data: z.infer<typeof completionSnapshotFormSchema>,
    completionSnapshotId: number
  ) => {
    const mappedData = divideAllCompletionPercentagesByAHundred(data);
    updateCompletionSnapshotMutation(
      {
        params: { path: { id: completionSnapshotId } },
        body: mappedData,
      },
      {
        onError: () => {
          toast({
            variant: "destructive",
            title: t("common.toast.error_title"),
            description: t("common.toast.error_description"),
          });
        },
        onSuccess: () => {
          toast({
            description: (
              <span className="flex gap-2">
                <Check className="text-primary" />
                {t(
                  "pages.companies.completion_snapshot.form.update_success_toast_message"
                )}
              </span>
            ),
          });
          navigate({
            to: "/companies/$companyId/projects/$projectId/completion_snapshots/$completionSnapshotId",
            params: {
              companyId: companyId.toString(),
              projectId: projectId.toString(),
              completionSnapshotId: completionSnapshotId.toString(),
            },
          });
        },
      }
    );
  };

  const onSubmit = (data: z.infer<typeof completionSnapshotFormSchema>) => {
    if (completionSnapshotId == undefined) {
      triggerCreateMutationAndRedirectToProjectShow(data);
    } else {
      triggerUpdateMutationAndRedirectToCompletionSnapshotShow(
        data,
        completionSnapshotId
      );
    }
  };

  let itemsInputs: number[] = [];

  return (
    <Form {...form}>
      <form
        onSubmit={form.handleSubmit(onSubmit)}
        className="flex flex-col flex-grow gap-4"
      >
        {itemGroups.map((item_group) => (
          <Card key={item_group.id}>
            <CardHeader>
              <CardTitle>{item_group.name}</CardTitle>
              {item_group.description && (
                <CardDescription>{item_group.name}</CardDescription>
              )}
            </CardHeader>
            <CardContent>
              <Table className="table-fixed">
                <TableHeader>
                  <TableRow>
                    <TableHead className="w-[35%]">
                      {t(
                        "pages.companies.completion_snapshot.form.details_label"
                      )}
                    </TableHead>
                    <TableHead className="w-[15%]">
                      {t(
                        "pages.companies.completion_snapshot.form.item_total_label"
                      )}
                    </TableHead>
                    <TableHead className="w-[35%]" colSpan={2}>
                      {t(
                        "pages.companies.completion_snapshot.form.previous_completion_percentage_label"
                      )}
                    </TableHead>
                    <TableHead className="w-[35%]" colSpan={2}>
                      {t(
                        "pages.companies.completion_snapshot.form.new_completion_percentage_label"
                      )}
                    </TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {item_group.grouped_items.map((item) => {
                    itemsInputs = [...itemsInputs, item.id];
                    return (
                      <ItemRow
                        key={item.id}
                        item={item}
                        inputIndex={itemsInputs.length - 1}
                        previousCompletionSnapshot={previousCompletionSnapshot}
                      />
                    );
                  })}
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        ))}
        <div className="flex justify-between">
          <TotalInfo
            itemGroups={itemGroups}
            previousCompletionSnapshot={previousCompletionSnapshot}
          />
          <FormSubmitButton />
        </div>
      </form>
    </Form>
  );
};

export { CompletionSnapshotForm };
