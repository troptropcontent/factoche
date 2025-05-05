import { KpiCard } from "./kpi-card";
import { Skeleton } from "@/components/ui/skeleton";

const KpiCardLoading = () => {
  return (
    <KpiCard.Root>
      <KpiCard.Header>
        <Skeleton className="h-8 w-full" />
        <Skeleton className="h-8 w-8 ml-3" />
      </KpiCard.Header>
      <KpiCard.Content>
        <Skeleton className="h-8 w-full mb-3" />
        <Skeleton className="h-8 w-full" />
      </KpiCard.Content>
    </KpiCard.Root>
  );
};

export { KpiCardLoading };
