import { getAccessToken } from "@/auth-utils";
import { Outlet, createFileRoute, redirect } from "@tanstack/react-router";

function AuthenticatedLayout() {
  return <Outlet />;
}

export const Route = createFileRoute("/_authenticated")({
  component: AuthenticatedLayout,
  beforeLoad: ({ location }) => {
    const token = getAccessToken();

    if (!token && !location.pathname.startsWith("/auth/login")) {
      throw redirect({
        to: "/auth/login",
        search: { redirect: location.href },
      });
    }
  },
});
