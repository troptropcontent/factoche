import { Header } from "@/features/companies/header";
import { MainSection } from "@/features/companies/main-section";
import { createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute(
  "/_authenticated/companies/$companyId/clients/"
)({
  component: RouteComponent,
});

function RouteComponent() {
  const { companyId } = Route.useParams();

  return (
    <>
      <Header>
        <h1>Mes clients</h1>
      </Header>
      <MainSection>
        <p>Liste des clients de la company {companyId}</p>
      </MainSection>
    </>
  );
}
