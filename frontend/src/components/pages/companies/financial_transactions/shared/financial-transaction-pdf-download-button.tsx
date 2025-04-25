import { Loader2 } from "lucide-react";

import { Link } from "@tanstack/react-router";

import { Button } from "@/components/ui/button";

import { Download } from "lucide-react";

const FinancialTransactionPdfDownloadButton = ({
  url,
  urlDefinedText,
  urlUndefinedText,
}: {
  url?: string | null;
  urlDefinedText: string;
  urlUndefinedText: string;
}) => {
  return (
    <Button asChild variant="outline">
      {url ? (
        <Link to={`${import.meta.env.VITE_API_BASE_URL}${url}`} target="_blank">
          <Download className="mr-2 h-4 w-4" />
          {urlDefinedText}
        </Link>
      ) : (
        <Link disabled>
          <Loader2 className="mr-2 h-4 w-4 animate-spin" />
          {urlUndefinedText}
        </Link>
      )}
    </Button>
  );
};

export { FinancialTransactionPdfDownloadButton };
