import { ReactNode } from "react";

const MainSection = ({ children }: { children: ReactNode }) => {
  return <div className="flex flex-1 flex-col gap-4 p-4">{children}</div>;
};

export { MainSection };
