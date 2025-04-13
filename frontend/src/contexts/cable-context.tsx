// CableContext.tsx
import React, { createContext, useMemo } from "react";
import { createConsumer } from "@rails/actioncable";

type CableContextType = {
  cable: ReturnType<typeof createConsumer> | null;
};

const CableContext = createContext<CableContextType>({ cable: null });

type Props = {
  token: string;
  companyId: number;
  children: React.ReactNode;
};

const CableContextProvider = ({ token, companyId, children }: Props) => {
  const cable = useMemo(
    () =>
      createConsumer(
        `${import.meta.env.VITE_API_BASE_URL}/cable?company_id=${companyId}&token=${token}`
      ),
    [companyId, token]
  );

  return (
    <CableContext.Provider value={{ cable }}>{children}</CableContext.Provider>
  );
};

export { CableContextProvider, CableContext };
