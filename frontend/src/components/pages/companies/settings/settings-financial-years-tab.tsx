import { useState } from "react";
import { useTranslation } from "react-i18next";
import { Api } from "@/lib/openapi-fetch-query-client";
import { useToast } from "@/hooks/use-toast";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { EmptyState } from "@/components/ui/empty-state";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { CalendarDays, Plus, RefreshCw } from "lucide-react";

function toISOFirstDayOfMonth(yearMonth: string): string {
  return new Date(`${yearMonth}-01T00:00:00.000Z`).toISOString();
}

function toISOLastDayOfMonth(yearMonth: string): string {
  const parts = yearMonth.split("-").map(Number);
  const year = parts[0] ?? 0;
  const month = parts[1] ?? 1;
  const lastDay = new Date(Date.UTC(year, month, 0));
  lastDay.setUTCHours(23, 59, 59, 999);
  return lastDay.toISOString();
}

function formatDate(dateStr: string): string {
  const [datePart] = dateStr.split("T");
  const [year, month, day] = (datePart ?? "").split("-");
  return `${day}/${month}/${year}`;
}

export function FinancialYearsTab({ companyId }: { companyId: number }) {
  const { t } = useTranslation();
  const { toast } = useToast();
  const [showNewForm, setShowNewForm] = useState(false);
  const [startMonth, setStartMonth] = useState("");
  const [endMonth, setEndMonth] = useState("");
  const [renewTargetId, setRenewTargetId] = useState<number | null>(null);

  const { data, refetch } = Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/financial_years",
    { params: { path: { company_id: companyId } } }
  );

  const { mutateAsync: createFinancialYear, isPending: isCreating } =
    Api.useMutation(
      "post",
      "/api/v1/organization/companies/{company_id}/financial_years"
    );

  const { mutateAsync: renewFinancialYear, isPending: isRenewing } =
    Api.useMutation("post", "/api/v1/organization/financial_years/{id}/renew");

  const financialYears = data?.results ?? [];

  // Most recent by end_date, not array position
  const mostRecentYear =
    financialYears.length > 0
      ? financialYears.reduce((latest, year) =>
          year.end_date > latest.end_date ? year : latest
        )
      : null;

  const isEndBeforeStart =
    !!startMonth && !!endMonth && endMonth < startMonth;

  function resetForm() {
    setShowNewForm(false);
    setStartMonth("");
    setEndMonth("");
  }

  async function handleCreate() {
    if (!startMonth || !endMonth || isEndBeforeStart) return;
    await createFinancialYear(
      {
        params: { path: { company_id: companyId } },
        body: {
          financial_year: {
            start_date: toISOFirstDayOfMonth(startMonth),
            end_date: toISOLastDayOfMonth(endMonth),
          },
        },
      },
      {
        onSuccess: () => {
          toast({
            variant: "success",
            title: t(
              "pages.companies.settings.forms.financial_years.create_success_title"
            ),
            description: t(
              "pages.companies.settings.forms.financial_years.create_success_description"
            ),
          });
          resetForm();
          refetch();
        },
        onError: () => {
          toast({
            variant: "destructive",
            title: t("pages.companies.settings.forms.shared.error_toast_title"),
            description: t(
              "pages.companies.settings.forms.shared.error_toast_description"
            ),
          });
        },
      }
    );
  }

  async function handleRenewConfirm() {
    if (renewTargetId === null) return;
    await renewFinancialYear(
      { params: { path: { id: renewTargetId } } },
      {
        onSuccess: () => {
          toast({
            variant: "success",
            title: t(
              "pages.companies.settings.forms.financial_years.renew_success_title"
            ),
            description: t(
              "pages.companies.settings.forms.financial_years.renew_success_description"
            ),
          });
          refetch();
        },
        onError: () => {
          toast({
            variant: "destructive",
            title: t("pages.companies.settings.forms.shared.error_toast_title"),
            description: t(
              "pages.companies.settings.forms.shared.error_toast_description"
            ),
          });
        },
      }
    );
    setRenewTargetId(null);
  }

  if (financialYears.length === 0 && !showNewForm) {
    return (
      <EmptyState
        icon={CalendarDays}
        title={t("pages.companies.settings.forms.financial_years.empty_title")}
        description={t(
          "pages.companies.settings.forms.financial_years.no_financial_years"
        )}
        action={
          <Button onClick={() => setShowNewForm(true)}>
            <Plus className="h-4 w-4 mr-2" />
            {t(
              "pages.companies.settings.forms.financial_years.add_financial_year"
            )}
          </Button>
        }
      />
    );
  }

  return (
    <>
      <div className="space-y-4">
        {financialYears.length > 0 && (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>
                  {t(
                    "pages.companies.settings.forms.financial_years.table.start_date"
                  )}
                </TableHead>
                <TableHead>
                  {t(
                    "pages.companies.settings.forms.financial_years.table.end_date"
                  )}
                </TableHead>
                <TableHead className="text-right">
                  {t(
                    "pages.companies.settings.forms.financial_years.table.actions"
                  )}
                </TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {financialYears.map((year) => (
                <TableRow key={year.id}>
                  <TableCell>{formatDate(year.start_date)}</TableCell>
                  <TableCell>{formatDate(year.end_date)}</TableCell>
                  <TableCell className="text-right">
                    {year.id === mostRecentYear?.id && (
                      <Button
                        onClick={() => setRenewTargetId(year.id)}
                        variant="outline"
                        size="sm"
                      >
                        <RefreshCw className="h-3.5 w-3.5 mr-1.5" />
                        {t(
                          "pages.companies.settings.forms.financial_years.renew"
                        )}
                      </Button>
                    )}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        )}

        {showNewForm ? (
          <div className="border rounded-lg p-4 space-y-4">
            <p className="text-sm font-medium">
              {t(
                "pages.companies.settings.forms.financial_years.new_financial_year"
              )}
            </p>
            <div className="flex items-end gap-4">
              <div className="space-y-1.5">
                <Label className="text-xs text-muted-foreground">
                  {t(
                    "pages.companies.settings.forms.financial_years.fields.start_month"
                  )}
                </Label>
                <Input
                  type="month"
                  className="w-44"
                  value={startMonth}
                  onChange={(e) => setStartMonth(e.target.value)}
                />
              </div>
              <div className="space-y-1.5">
                <Label className="text-xs text-muted-foreground">
                  {t(
                    "pages.companies.settings.forms.financial_years.fields.end_month"
                  )}
                </Label>
                <Input
                  type="month"
                  className={`w-44 ${isEndBeforeStart ? "border-destructive" : ""}`}
                  value={endMonth}
                  onChange={(e) => setEndMonth(e.target.value)}
                />
                {isEndBeforeStart && (
                  <p className="text-xs text-destructive">
                    {t(
                      "pages.companies.settings.forms.financial_years.fields.end_before_start"
                    )}
                  </p>
                )}
              </div>
              <div className="flex gap-2">
                <Button variant="outline" onClick={resetForm}>
                  {t("pages.companies.settings.forms.financial_years.cancel")}
                </Button>
                <Button
                  onClick={handleCreate}
                  disabled={
                    !startMonth || !endMonth || isEndBeforeStart || isCreating
                  }
                >
                  {t("pages.companies.settings.forms.financial_years.create")}
                </Button>
              </div>
            </div>
          </div>
        ) : (
          <div className="flex justify-end">
            <Button
              variant="outline"
              size="sm"
              onClick={() => setShowNewForm(true)}
            >
              <Plus className="h-4 w-4 mr-2" />
              {t(
                "pages.companies.settings.forms.financial_years.add_financial_year"
              )}
            </Button>
          </div>
        )}
      </div>

      <Dialog
        open={renewTargetId !== null}
        onOpenChange={(open) => !open && setRenewTargetId(null)}
      >
        <DialogContent>
          <DialogHeader>
            <DialogTitle>
              {t(
                "pages.companies.settings.forms.financial_years.renew_dialog.title"
              )}
            </DialogTitle>
            <DialogDescription>
              {t(
                "pages.companies.settings.forms.financial_years.renew_dialog.description"
              )}
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button variant="outline" onClick={() => setRenewTargetId(null)}>
              {t("pages.companies.settings.forms.financial_years.cancel")}
            </Button>
            <Button onClick={handleRenewConfirm} disabled={isRenewing}>
              {t(
                "pages.companies.settings.forms.financial_years.renew_dialog.confirm"
              )}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </>
  );
}
