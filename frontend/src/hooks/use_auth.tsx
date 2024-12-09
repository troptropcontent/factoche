import { useContext } from "react";

import { useQueryClient } from "@tanstack/react-query";
import { AuthContext } from "../contexts/auth_context";

const useAuth = () => {
  const authContext = useContext(AuthContext);
  const queryClient = useQueryClient()
  if (queryClient === null) {
    throw new Error("useAuth must be used within an QueryClient");
  }

  const getAccessToken = () => localStorage.getItem("accessToken");
  const getRefreshToken = () => localStorage.getItem("refreshToken");


  const login = (accessToken: string, refreshToken?: string) => {
    if (authContext === null) {
      throw new Error("useAuth#login must be used within an AuthContext");
    }
    localStorage.setItem("accessToken", accessToken);
    if (refreshToken) {
      localStorage.setItem("refreshToken", refreshToken);
    }
    authContext.setIsAuthed(true);
  };

  const logout = () => {
    if (authContext === null) {
      throw new Error("useAuth#logout must be used within an AuthContext");
    }
    localStorage.removeItem("accessToken");
    localStorage.removeItem("refreshToken");
    queryClient.clear()
    authContext.setIsAuthed(false);
  };

  const getAuthStatus = () => {
    const accessToken = getAccessToken();
    const refreshToken = getRefreshToken();
    return accessToken !== null && refreshToken !== null;
  };

  const isAuthed = () => {
    if (authContext === null) {
      throw new Error("useAuth#isAuthed must be used within an AuthContext");
    }
    return authContext.isAuthed;
  };

  const isTokenValid = (token: string | null): boolean => {
    if (!token) return false;
    try {
      // TODO create /auth/validate endpoint and use it to validate the token
      // For now, just return true
      return true;
    } catch {
      return false;
    }
  };

  const handleStorageChange = (e: StorageEvent) => {
    if (authContext === null) {
      throw new Error("useAuth#handleStorageChange must be used within an AuthContext");
    }
    if (e.key === "accessToken" && isTokenValid(e.newValue)) {
      authContext.setIsAuthed(true);
    } else {
      authContext.setIsAuthed(false);
    }
  };

  const setLocalStorageEventHandler = () => {
    window.addEventListener("storage", handleStorageChange);
  };

  const clearLocalStorageEventHandler = () => {
    window.removeEventListener("storage", handleStorageChange);
  };

  return { isAuthed, getAccessToken, getRefreshToken, login, logout, getAuthStatus, setLocalStorageEventHandler, clearLocalStorageEventHandler };
};

export { useAuth };
