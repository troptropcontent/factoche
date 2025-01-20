import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Trash } from "lucide-react";
import { ReactNode } from "react";

const ItemCardLayout = ({
  remove,
  children,
}: {
  remove: () => void;
  children: ReactNode;
}) => {
  return (
    <Card className="mb-4 last:mb-0">
      <CardContent className="flex p-0">
        <div className="p-6 flex-grow">{children}</div>
        <Button
          variant="secondary"
          onClick={remove}
          className="h-auto rounded-l-none"
        >
          <Trash />
        </Button>
      </CardContent>
    </Card>
  );
};

export { ItemCardLayout };
