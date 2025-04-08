import { Layout } from "@/components/pages/companies/layout";
import { QuoteStatusBadge } from "@/components/pages/companies/quotes/shared/quote-status-badge";
import { Button } from "@/components/ui/button";
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
  "/_authenticated/companies/$companyId/quotes/"
)({
  component: RouteComponent,
});

function RouteComponent() {
  const { companyId } = Route.useParams();
  const { t } = useTranslation();
  const { data: quotes = [] } = Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/quotes",
    { params: { path: { company_id: Number(companyId) } } },
    { select: ({ results }) => results }
  );
  const navigate = useNavigate();
  const handleRowClick = (quoteId: number) => {
    navigate({
      to: "/companies/$companyId/quotes/$quoteId",
      params: { companyId: companyId, quoteId: quoteId.toString() },
    });
  };

  return (
    <Layout.Root>
      <Layout.Header>
        <div className="flex flex-grow justify-between items-center">
          <h1 className="text-3xl font-bold">
            {t("pages.companies.quotes.index.title")}
          </h1>
          <Button asChild>
            <Link
              to={`/companies/$companyId/quotes/new`}
              params={{ companyId }}
            >
              <PlusCircle className="mr-2 h-4 w-4" />
              {t("pages.companies.quotes.index.add_quote")}
            </Link>
          </Button>
        </div>
      </Layout.Header>
      <Layout.Content>
        <div className="container mx-auto">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>
                  {t("pages.companies.quotes.index.table.columns.number")}
                </TableHead>
                <TableHead>
                  {t("pages.companies.quotes.index.table.columns.name")}
                </TableHead>
                <TableHead>
                  {t("pages.companies.quotes.index.table.columns.client")}
                </TableHead>
                <TableHead>
                  {t("pages.companies.quotes.index.table.columns.amount")}
                </TableHead>
                <TableHead>
                  {t("pages.companies.quotes.index.table.columns.status")}
                </TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {quotes.map((quote) => (
                <TableRow
                  key={quote.id}
                  onClick={() => handleRowClick(quote.id)}
                  className="cursor-pointer hover:bg-gray-100 transition-colors"
                  role="link"
                  tabIndex={0}
                  onKeyDown={(e) => {
                    if (e.key === "Enter" || e.key === " ") {
                      e.preventDefault();
                      handleRowClick(quote.id);
                    }
                  }}
                >
                  <TableCell className="font-medium">{quote.number}</TableCell>
                  <TableCell title={quote.name}>{quote.name}</TableCell>
                  <TableCell>{quote.client.name}</TableCell>
                  <TableCell>
                    {t("common.number_in_currency", {
                      amount: parseFloat(quote.last_version.total_amount),
                    })}
                  </TableCell>
                  <TableCell>
                    <QuoteStatusBadge posted={quote.posted} />
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
