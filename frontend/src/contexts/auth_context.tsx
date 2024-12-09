import { createContext, useState, useEffect, ReactNode } from "react";
import { useAuth } from "../hooks/use_auth";

type AuthContextType = {
  isAuthed: boolean;
  setIsAuthed: (isAuthed: boolean) => void;
} | null;

const AuthContext = createContext<AuthContextType>(null);

type AuthContextProviderProps = {
  children: ReactNode
};

const Provider = ({ children }: AuthContextProviderProps) => {
    const { getAuthStatus } = useAuth();
    console.log({ authStatus: getAuthStatus() });
    const [isAuthed, setIsAuthed] = useState<boolean>(getAuthStatus());

    return (
        <AuthContext.Provider value={{ isAuthed, setIsAuthed }}>
            {children}
        </AuthContext.Provider>
    )
}

const Consumer = ({ children }: { children: ReactNode }) => {
    const { setLocalStorageEventHandler, clearLocalStorageEventHandler } = useAuth();
      useEffect(() => {
        setLocalStorageEventHandler();
        return clearLocalStorageEventHandler;
      }, [setLocalStorageEventHandler, clearLocalStorageEventHandler]);

    return (
        <>
            {children}
        </>
    )
}


const AuthContextProvider = ({ children }: AuthContextProviderProps) => {
  


  return (
    <Provider>
        <Consumer>
            {children}
        </Consumer>
    </Provider>
  );
}; 

export { AuthContext, AuthContextProvider };
export type { AuthContextType };