import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { type LucideIcon } from "lucide-react";

interface EmptyStateProps {
  icon: LucideIcon;
  title: string;
  description: string;
  actionLabel: string;
  onAction: () => void;
  className?: string;
}

export function EmptyState({
  icon: Icon,
  title,
  description,
  actionLabel,
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
      <Button onClick={onAction}>{actionLabel}</Button>
    </div>
  );
}
