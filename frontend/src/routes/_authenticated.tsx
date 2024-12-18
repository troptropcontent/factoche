import { isAuthed } from "@/lib/auth-service";
import { Outlet, createFileRoute, redirect } from "@tanstack/react-router";

function AuthenticatedLayout() {
  return <Outlet />;
}

export const Route = createFileRoute("/_authenticated")({
  beforeLoad: ({ location }) => {
    if (!isAuthed()) {
      throw redirect({
        to: "/auth/login",
        search: {
          redirect: location.href,
        },
      });
    }
  },
  component: AuthenticatedLayout,
});
