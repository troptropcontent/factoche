import createFetchClient, { type Middleware } from "openapi-fetch";
import createQueryClient from "openapi-react-query";
import type { paths } from "./openapi-fetch-schemas";
import { clearAccessToken, getAccessToken } from "@/auth-utils";

const fetchClient = (function () {
  const authMiddleware: Middleware = {
    async onRequest({ request }) {
      const accessToken = getAccessToken();

      if (accessToken) {
        request.headers.set("Authorization", `Bearer ${accessToken}`);
      }

      return request;
    },
    async onResponse({ response }) {
      if (response.status === 403) {
        clearAccessToken();
      }

      return response;
    },
  };

  // We had to manually add querySerializer because our rails backend
  const client = createFetchClient<paths>({
    baseUrl: import.meta.env.VITE_API_BASE_URL,
    querySerializer: (queryParams: Record<string, unknown>) => {
      const search: string[] = [];
      for (const name in queryParams) {
        const value = queryParams[name];
        if (Array.isArray(value)) {
          for (const item of value) {
            search.push(`${name}[]=${encodeURIComponent(String(item))}`);
          }
        } else {
          search.push(`${name}=${encodeURIComponent(String(value))}`);
        }
      }
      return search.join("&");
    },
  });

  client.use(authMiddleware);

  return client;
})();

const Api = createQueryClient(fetchClient);

export { Api };
