import { Layout } from "@/components/pages/companies/layout";
import { Badge } from "@/components/ui/badge";
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
import { Api } from "@/lib/openapi-fetch-query-client";
import { createFileRoute, Link, useNavigate } from "@tanstack/react-router";
import { PlusCircle } from "lucide-react";

import { useTranslation } from "react-i18next";

export const Route = createFileRoute(
  "/_authenticated/companies/$companyId/projects/"
)({
  component: RouteComponent,
});

const getStatusColor = (status: string) => {
  switch (status) {
    case "new":
      return "bg-gray-500";
    case "invoicing_in_progress":
      return "bg-yellow-500";
    case "invoiced":
      return "bg-blue-500";
    case "canceled":
      return "bg-purple-500";
    default:
      return "bg-gray-500";
  }
};

function RouteComponent() {
  const { companyId } = Route.useParams();
  const { t } = useTranslation();
  const { data: { results: projects } = { results: [] } } = Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/projects",
    { params: { path: { company_id: Number(companyId) } } }
  );
  const navigate = useNavigate();
  const handleRowClick = (projectId: number) => {
    navigate({
      to: "/companies/$companyId/projects/$projectId",
      params: { companyId: companyId, projectId: projectId.toString() },
    });
  };

  return (
    <Layout.Root>
      <Layout.Header>
        <div className="flex flex-grow justify-between items-center">
          <h1 className="text-3xl font-bold">
            {t("pages.companies.projects.index.title")}
          </h1>
          <Button asChild>
            <Link
              to={`/companies/$companyId/projects/new`}
              params={{ companyId }}
            >
              <PlusCircle className="mr-2 h-4 w-4" />
              {t("pages.companies.projects.index.add_project")}
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
          </div>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>
                  {t("pages.companies.projects.index.table.columns.name")}
                </TableHead>
                <TableHead>
                  {t("pages.companies.projects.index.table.columns.status")}
                </TableHead>
                <TableHead>
                  {t("pages.companies.projects.index.table.columns.client")}
                </TableHead>
                <TableHead>
                  {t(
                    "pages.companies.projects.index.table.columns.total_amount"
                  )}
                </TableHead>
                <TableHead>
                  {t(
                    "pages.companies.projects.index.table.columns.invoiced_amount"
                  )}
                </TableHead>
                <TableHead>
                  {t(
                    "pages.companies.projects.index.table.columns.remaining_amount"
                  )}
                </TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {projects.map((project) => (
                <TableRow
                  key={project.id}
                  onClick={() => handleRowClick(project.id)}
                  className="cursor-pointer hover:bg-gray-100 transition-colors"
                  role="link"
                  tabIndex={0}
                  onKeyDown={(e) => {
                    if (e.key === "Enter" || e.key === " ") {
                      e.preventDefault();
                      handleRowClick(project.id);
                    }
                  }}
                >
                  <TableCell className="font-medium">{project.name}</TableCell>
                  <TableCell>
                    <Badge
                      className={`${getStatusColor(project.status)} text-white`}
                    >
                      {project.status}
                    </Badge>
                  </TableCell>
                  <TableCell>{project.client.name}</TableCell>
                  <TableCell>
                    {t("common.number_in_currency", {
                      amount: parseFloat(project.last_version.total_amount),
                    })}
                  </TableCell>
                  <TableCell>
                    {t("common.number_in_currency", {
                      amount: parseFloat(project.invoiced_amount),
                    })}
                  </TableCell>
                  <TableCell>
                    {t("common.number_in_currency", {
                      amount:
                        parseFloat(project.last_version.total_amount) -
                        parseFloat(project.invoiced_amount),
                    })}
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
