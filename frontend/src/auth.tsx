import { createContext, ReactNode, useState } from "react";
import { Api } from "./lib/openapi-fetch-query-client";
import { ACCESS_TOKEN_KEY, REFRESH_TOKEN_KEY } from "./auth-constants";
import { getAccessToken } from "./auth-utils";

type AuthContextType = {
  accessToken: string | null;
  setAccessToken: (token: string | null) => void;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
} | null;

const AuthContext = createContext<AuthContextType>(null);

const AuthProvider = ({ children }: { children: ReactNode }) => {
  const [accessToken, setAccessTokenState] = useState<string | null>(
    getAccessToken()
  );
  const { mutateAsync: loginMutationAsync } = Api.useMutation(
    "post",
    "/api/v1/auth/login"
  );

  const setAccessToken = (token: string | null) => {
    if (token) {
      localStorage.setItem(ACCESS_TOKEN_KEY, token);
    } else {
      localStorage.removeItem(ACCESS_TOKEN_KEY);
    }
    setAccessTokenState(token);
  };

  const setRefreshToken = (token: string | null) => {
    if (token) {
      localStorage.setItem(REFRESH_TOKEN_KEY, token);
    } else {
      localStorage.removeItem(REFRESH_TOKEN_KEY);
    }
  };

  const login = async (email: string, password: string) => {
    await loginMutationAsync(
      { body: { session: { email, password } } },
      {
        onSuccess: ({ access_token, refresh_token }) => {
          setAccessToken(access_token);
          setRefreshToken(refresh_token);
        },
      }
    );
  };

  const logout = () => {
    setAccessToken(null);
    setRefreshToken(null);
  };

  return (
    <AuthContext.Provider
      value={{ accessToken, setAccessToken, login, logout }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export { AuthProvider, AuthContext };
