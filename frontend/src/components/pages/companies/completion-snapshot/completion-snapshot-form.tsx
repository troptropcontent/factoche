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
import { Button } from "@/components/ui/button";
import { buildInitialValues } from "./completion-snapshot-form.utils";
import { ItemRow } from "./item-row";
import { TotalInfo } from "./total-info";
import { Api } from "@/lib/openapi-fetch-query-client";
import { completionSnapshotFormSchema } from "./completion-snapshot-form.schemas";
import { useNavigate } from "@tanstack/react-router";

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
};

const CompletionSnapshotForm = ({
  companyId,
  projectId,
  itemGroups,
  previousCompletionSnapshot,
}: CompletionSnapshotFormType) => {
  const { t } = useTranslation();
  const { mutate: createCompletionSnapshotMutation } = Api.useMutation(
    "post",
    "/api/v1/organization/companies/{company_id}/projects/{project_id}/completion_snapshots"
  );
  const form = useForm<z.infer<typeof completionSnapshotFormSchema>>({
    resolver: zodResolver(completionSnapshotFormSchema),
    defaultValues: buildInitialValues({
      itemGroups,
      previousCompletionSnapshot,
    }),
  });

  const navigate = useNavigate();

  const onSubmit = (data: z.infer<typeof completionSnapshotFormSchema>) => {
    createCompletionSnapshotMutation(
      {
        params: { path: { company_id: companyId, project_id: projectId } },
        body: data,
      },
      {
        onSuccess: () =>
          navigate({
            to: "/companies/$companyId/projects/$projectId",
            params: {
              companyId: companyId.toString(),
              projectId: projectId.toString(),
            },
          }),
      }
    );
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
          <Button type="submit">
            {t("pages.companies.completion_snapshot.form.submit_button_label")}
          </Button>
        </div>
      </form>
    </Form>
  );
};

export { CompletionSnapshotForm };
