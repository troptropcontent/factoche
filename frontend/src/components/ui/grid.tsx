import * as React from "react";
import { cn } from "@/lib/utils";

const Grid = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => {
  return <div className={cn("grid", className)} ref={ref} {...props} />;
});
Grid.displayName = "Grid";

export { Grid };
