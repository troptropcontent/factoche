import { Suspense } from "react";
import { SettingsForm } from "./settings-form";
import { Skeleton } from "@/components/ui/skeleton";

const SettingsContentSkeleton = () => {
  return (
    <div className="space-y-6">
      <div className="space-y-2">
        <Skeleton className="h-5 w-40" />
        <Skeleton className="h-10 w-full" />
      </div>
      <div className="space-y-2">
        <Skeleton className="h-5 w-40" />
        <Skeleton className="h-10 w-full" />
      </div>
      <div className="space-y-2">
        <Skeleton className="h-5 w-40" />
        <Skeleton className="h-10 w-full" />
      </div>
      <div className="space-y-2">
        <Skeleton className="h-5 w-40" />
        <Skeleton className="h-10 w-full" />
      </div>
      <Skeleton className="h-10 w-32" />
    </div>
  );
};

const SettingsContent = ({ companyId }: { companyId: number }) => {
  return (
    <Suspense fallback={<SettingsContentSkeleton />}>
      <SettingsForm companyId={companyId} />
    </Suspense>
  );
};

export { SettingsContent };
