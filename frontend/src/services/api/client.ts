import { paths } from "./openapi/schema";
import { getAccessToken } from "@/lib/auth-service";
import axios from "axios";

const buildApiClient = () => {
  const apiClient = axios.create({
    baseURL: import.meta.env.VITE_API_BASE_URL,
  });

  // Add a request interceptor to add the auth token
  apiClient.interceptors.request.use((config) => {
    const accessToken = getAccessToken();

    if (accessToken) {
      config.headers.Authorization = `Bearer ${accessToken}`;
    }
    return config;
  });

  return apiClient;
};

type Path = keyof paths;

type PathMethod<T extends Path> = keyof paths[T];

type RequestPathParams<
  P extends Path,
  M extends PathMethod<P>,
> = paths[P][M] extends {
  parameters: { path: object };
}
  ? paths[P][M]["parameters"]["path"]
  : never;

type RequestBodyParams<
  P extends Path,
  M extends PathMethod<P>,
> = paths[P][M] extends {
  requestBody: { content: { "application/json": object } };
}
  ? paths[P][M]["requestBody"]["content"]["application/json"]
  : never;

type RequestWithBodyOptions<P extends Path, M extends PathMethod<P>> = {
  path: RequestPathParams<P, M>;
  body: RequestBodyParams<P, M>;
};

type RequestWithoutBodyOptions<P extends Path, M extends PathMethod<P>> =
  RequestPathParams<P, M> extends never
    ? null
    : {
        path: RequestPathParams<P, M>;
      };

type Response<P extends Path, M extends PathMethod<P>> = paths[P][M] extends {
  responses: { 200: { content: { "application/json": object } } };
}
  ? paths[P][M]["responses"][200]["content"]["application/json"]
  : never;

type PostPath = {
  [P in Path]: paths[P]["post"] extends never | undefined ? never : P;
}[Path];

type GetPath = {
  [P in Path]: paths[P]["get"] extends never | undefined ? never : P;
}[Path];

class ApiClass {
  #axiosInstance = buildApiClient();
  #replacePathParams = (
    path: string,
    params: Record<string, string | number>
  ) => {
    return path.replace(/{([^}]+)}/g, (_, key) => String(params[key]));
  };

  POST<P extends PostPath>(path: P, params: RequestWithBodyOptions<P, "post">) {
    const url = params.path ? this.#replacePathParams(path, params.path) : path;
    return this.#axiosInstance.post<Response<P, "post">>(url, params.body);
  }

  GET<P extends GetPath>(path: P, params: RequestWithoutBodyOptions<P, "get">) {
    const url = params?.path
      ? this.#replacePathParams(path, params.path)
      : path;
    return this.#axiosInstance.get<Response<P, "get">>(url);
  }
}

const Api = new ApiClass();

export { Api };
