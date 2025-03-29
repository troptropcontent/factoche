import { TabsTrigger } from "@/components/ui/tabs";
import { Tab } from "../shared/types";
import { Badge } from "@/components/ui/badge";
import { Loader2 } from "lucide-react";
import { useTranslation } from "react-i18next";

const TabTrigger = ({
  documents,
  tab,
}: {
  documents: unknown[] | undefined;
  tab: Tab;
}) => {
  const { t } = useTranslation();
  return (
    <TabsTrigger value={tab}>
      {t(`pages.companies.projects.invoices.index.tabs.${tab}.label`)}
      <Badge variant="outline" className="ml-2">
        {documents === undefined ? (
          <Loader2 size={"1rem"} className="animate-spin" />
        ) : (
          documents.length
        )}
      </Badge>
    </TabsTrigger>
  );
};

export { TabTrigger };
