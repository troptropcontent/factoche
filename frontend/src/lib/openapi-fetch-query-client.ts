import createFetchClient, { type Middleware } from "openapi-fetch";
import createQueryClient from "openapi-react-query";
import type { paths } from "./openapi-fetch-schemas";
import { getAccessToken } from "./auth-service";

const fetchClient = (function () {
  const authMiddleware: Middleware = {
    async onRequest({ request }) {
      const accessToken = getAccessToken();

      if (accessToken) {
        request.headers.set("Authorization", `Bearer ${accessToken}`);
      }

      return request;
    },
  };

  const client = createFetchClient<paths>({
    baseUrl: import.meta.env.VITE_API_BASE_URL,
  });

  client.use(authMiddleware);

  return client;
})();

const Api = createQueryClient(fetchClient);

export { Api };
