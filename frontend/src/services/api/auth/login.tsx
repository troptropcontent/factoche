import { AxiosInstance } from "axios";

const login = (client: AxiosInstance) => {
  return async (data: {
    email: string;
    password: string;
  }): Promise<{ access_token: string; refresh_token: string }> => {
    const response = await client.post("/api/v1/auth/login", { session: data });
    return response.data;
  };
};

export { login };
