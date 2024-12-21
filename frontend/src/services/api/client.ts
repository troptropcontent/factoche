import { paths } from "./openapi/schema";
import createClient, { Middleware } from "openapi-fetch";
import { getAccessToken } from "@/lib/auth-service";

const authMidleware: Middleware = {
  async onRequest({ request }) {
    const accessToken = getAccessToken();

    if (accessToken) {
      request.headers.set("Authorization", `Bearer ${accessToken}`);
    }

    return request;
  },
};

const client = createClient<paths>({
  baseUrl: import.meta.env.VITE_API_BASE_URL,
});

client.use(authMidleware);

export { client };
