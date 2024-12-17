import { useContext } from "react";
import { AuthContext } from "../contexts/auth_context";
import axios, { AxiosRequestConfig } from "axios";
import { useAuth } from "./use_auth";

// Create a constant for the base configuration
const baseAxiosConfig = {
  baseURL: import.meta.env.VITE_API_BASE_URL,
};

const useAuthentifiedAxiosInstance = () => {
  const { getAccessToken, getRefreshToken, logout, login } = useAuth();

  const instance = axios.create({
    ...baseAxiosConfig,
    headers: {
      Authorization: `Bearer ${getAccessToken()}`,
    },
  });

  // Separate the error handler logic for clarity
  const handleRefreshToken = async (originalRequest: AxiosRequestConfig) => {
    try {
      const response = await axios.post(
        `${baseAxiosConfig.baseURL}/auth/refresh`,
        {
          refreshToken: getRefreshToken(),
        },
      );

      const { accessToken } = response.data;
      login(accessToken);

      if (!originalRequest.headers) {
        originalRequest.headers = {};
      }
      originalRequest.headers.Authorization = `Bearer ${accessToken}`;
      return instance(originalRequest);
    } catch (refreshError) {
      logout();
      return Promise.reject(refreshError);
    }
  };

  instance.interceptors.response.use(
    (response) => response,
    async (error) => {
      const originalRequest = error.config;

      if (error.response?.status === 401 && !originalRequest._retry) {
        originalRequest._retry = true;
        return handleRefreshToken(originalRequest);
      }

      return Promise.reject(error);
    },
  );

  return instance;
};

const useUnauthentifiedAxiosInstance = () => {
  return axios.create(baseAxiosConfig);
};

// depending on if the user is authentified or not this hook return an authentified axios instance
const useApiClient = () => {
  const authContext = useContext(AuthContext);
  const authentifiedAxiosInstance = useAuthentifiedAxiosInstance();
  const unauthentifiedAxiosInstance = useUnauthentifiedAxiosInstance();
  if (authContext === null) {
    throw new Error("useApiClient must be used within an AuthContext");
  }
  const { isAuthed } = authContext;
  if (isAuthed) {
    return authentifiedAxiosInstance;
  } else {
    return unauthentifiedAxiosInstance;
  }
};

export { useApiClient };
