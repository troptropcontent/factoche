import { Layout } from "@/components/pages/companies/layout";
import { SettingsContent } from "@/components/pages/companies/settings/settings-content";
import { createFileRoute } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";

export const Route = createFileRoute(
  "/_authenticated/companies/$companyId/settings"
)({
  component: RouteComponent,
});

function RouteComponent() {
  const { companyId } = Route.useParams();
  const { t } = useTranslation();
  return (
    <Layout.Root>
      <Layout.Header>
        <div className="flex flex-grow justify-between items-center">
          <h1 className="text-3xl font-bold">
            {t("pages.companies.settings.title")}
          </h1>
        </div>
      </Layout.Header>
      <Layout.Content>
        <SettingsContent companyId={Number(companyId)} />
      </Layout.Content>
    </Layout.Root>
  );
}
