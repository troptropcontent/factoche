import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { type LucideIcon } from "lucide-react";
import { ReactNode } from "react";

interface BaseEmptyStateProps {
  icon: LucideIcon;
  title: string;
  description: string;
  className?: string;
}

type EmptyStateProps =
  | (BaseEmptyStateProps & { action: string; onAction: () => void })
  | (BaseEmptyStateProps & { action: ReactNode; onAction?: () => void });

export function EmptyState({
  icon: Icon,
  title,
  description,
  action,
  className,
  onAction,
}: EmptyStateProps) {
  return (
    <div
      className={cn(
        "flex flex-col items-center justify-center min-h-[400px] bg-muted/40 rounded-lg p-8 text-center",
        className
      )}
    >
      <Icon className="w-16 h-16 text-muted-foreground mb-4" />
      <h3 className="text-2xl font-semibold mb-2">{title}</h3>
      <p className="text-muted-foreground mb-6 max-w-sm">{description}</p>
      {typeof action == "string" ? (
        <Button onClick={onAction}>{action}</Button>
      ) : (
        action
      )}
    </div>
  );
}
