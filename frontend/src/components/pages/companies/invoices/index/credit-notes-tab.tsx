import { TabsContent } from "@/components/ui/tabs";

import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { useTranslation } from "react-i18next";
import { useCreditNotesQuery } from "../private/hooks";
import { CreditNotesTable } from "./private/credit-notes-table";
import { TabTrigger } from "./private/tab-trigger";

const TAB_VALUE = "creditNotes" as const;

const Trigger = ({ companyId }: { companyId: string }) => {
  const { data: creditNotes } = useCreditNotesQuery(companyId);
  return <TabTrigger documents={creditNotes} tab={TAB_VALUE} />;
};

const Content = ({ companyId }: { companyId: string }) => {
  const { data: creditNotes } = useCreditNotesQuery(companyId);
  const { t } = useTranslation();
  return (
    <TabsContent value={TAB_VALUE}>
      <Card>
        <CardHeader>
          <CardTitle>
            {t(
              "pages.companies.projects.invoices.index.tabs.creditNotes.title"
            )}
          </CardTitle>
          <CardDescription>
            {t(
              "pages.companies.projects.invoices.index.tabs.creditNotes.description"
            )}
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="overflow-x-auto">
            <CreditNotesTable creditNotes={creditNotes} />
          </div>
        </CardContent>
      </Card>
    </TabsContent>
  );
};

const CreditNotesTab = { Content, Trigger };

export { CreditNotesTab };
