"use client";

import { useState, useEffect, type ReactNode } from "react";
import { Loader2 } from "lucide-react";

interface LoadingWrapperProps {
  children: ReactNode;
  isLoading?: boolean;
  fallback?: ReactNode;
  delay?: number; // Optional delay before showing loader (prevents flashing for quick loads)
}

const LoadingWrapper = ({
  children,
  isLoading,
  fallback,
  delay = 300,
}: LoadingWrapperProps) => {
  const [showLoader, setShowLoader] = useState(isLoading && !delay);

  useEffect(() => {
    if (!isLoading) {
      setShowLoader(false);
      return;
    }

    const timer = setTimeout(() => {
      if (isLoading) {
        setShowLoader(true);
      }
    }, delay);

    return () => clearTimeout(timer);
  }, [isLoading, delay]);

  if (showLoader) {
    return (
      fallback || (
        <div className="flex items-center justify-center w-full h-full min-h-[100px] py-8">
          <Loader2 className="w-8 h-8 animate-spin text-muted-foreground" />
        </div>
      )
    );
  }

  return <>{children}</>;
};

export { LoadingWrapper };
