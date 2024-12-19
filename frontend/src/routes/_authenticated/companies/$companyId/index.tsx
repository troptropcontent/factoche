import { Header } from "@/components/pages/companies/header";
import { MainSection } from "@/components/pages/companies/main-section";
import { createFileRoute } from "@tanstack/react-router";
import { useTranslation } from 'react-i18next';

export const Route = createFileRoute("/_authenticated/companies/$companyId/")({
  component: RouteComponent,
});

function RouteComponent() {
  const { companyId } = Route.useParams();
  const { t } = useTranslation();
  return (
    <>
      <Header>
        <h1>{t("pages.companies.show.title")}</h1>
      </Header>
      <MainSection>
        <p>{t("pages.companies.show.description", {companyId})}</p>
      </MainSection>
    </>
  );
}
