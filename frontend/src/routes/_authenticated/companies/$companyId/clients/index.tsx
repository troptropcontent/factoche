import { createFileRoute } from "@tanstack/react-router";
import { PlusCircle } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Link } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";
import { Layout } from "@/components/pages/companies/layout";
import { Api } from "@/lib/openapi-fetch-query-client";

export const Route = createFileRoute(
  "/_authenticated/companies/$companyId/clients/"
)({
  component: RouteComponent,
  loader: ({ context: { queryClient }, params: { companyId } }) =>
    queryClient.ensureQueryData(
      Api.queryOptions(
        "get",
        "/api/v1/organization/companies/{company_id}/clients",
        { params: { path: { company_id: Number(companyId) } } }
      )
    ),
});

function RouteComponent() {
  const { companyId } = Route.useParams();
  const { t } = useTranslation();
  const clients = Route.useLoaderData();

  return (
    <Layout.Root>
      <Layout.Header>
        <div className="flex flex-grow justify-between items-center">
          <h1 className="text-3xl font-bold">
            {t("pages.companies.clients.index.title")}
          </h1>
          <Button asChild>
            <Link
              to={`/companies/$companyId/clients/new`}
              params={{ companyId }}
            >
              <PlusCircle className="mr-2 h-4 w-4" />
              {t("pages.companies.clients.index.add_client")}
            </Link>
          </Button>
        </div>
      </Layout.Header>
      <Layout.Content>
        <div className="container mx-auto">
          <div className="flex justify-between items-center mb-4">
            {/* TODO: Implement search and sort functionality */}
            <Input
              placeholder={t(
                "pages.companies.clients.index.search.placeholder"
              )}
              className="max-w-sm"
            />
            {/* <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="outline">{t("pages.companies.clients.index.sort_by.label")}</Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end">
                <DropdownMenuItem>{t("pages.companies.clients.index.sort_by.options.name")}</DropdownMenuItem>
                <DropdownMenuItem>{t("pages.companies.clients.index.sort_by.options.name_desc")}</DropdownMenuItem>
                <DropdownMenuItem>{t("pages.companies.clients.index.sort_by.options.email")}</DropdownMenuItem>
                <DropdownMenuItem>{t("pages.companies.clients.index.sort_by.options.email_desc")}</DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu> */}
          </div>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>
                  {t("pages.companies.clients.index.table.name")}
                </TableHead>
                <TableHead>
                  {t("pages.companies.clients.index.table.email")}
                </TableHead>
                <TableHead>
                  {t("pages.companies.clients.index.table.phone")}
                </TableHead>
                <TableHead className="text-right">
                  {t("pages.companies.clients.index.table.actions")}
                </TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              <TableRow className="only:table-row hidden">
                <TableCell colSpan={4}>
                  <div className="flex flex-col items-center justify-center h-32 text-center">
                    <PlusCircle className="w-10 h-10 text-gray-400 mb-2" />
                    <h3 className="text-lg font-medium">
                      {t(
                        "pages.companies.clients.index.table.empty_state.title"
                      )}
                    </h3>
                    <p className="text-sm text-gray-500">
                      {t(
                        "pages.companies.clients.index.table.empty_state.description"
                      )}
                    </p>
                  </div>
                </TableCell>
              </TableRow>
              {clients.map((client) => (
                <TableRow key={client.id}>
                  <TableCell className="font-medium">{client.name}</TableCell>
                  <TableCell>{client.email}</TableCell>
                  <TableCell>{client.phone}</TableCell>
                  <TableCell className="text-right">
                    <Button variant="ghost" size="sm" asChild>
                      <Link to={`/${client.id}`}>View</Link>
                    </Button>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
      </Layout.Content>
    </Layout.Root>
  );
}
