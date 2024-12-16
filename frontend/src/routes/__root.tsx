import { createRootRoute, Outlet, useNavigate } from "@tanstack/react-router";

import React, { useEffect } from "react";
import { useAuth } from "../hooks/use_auth";

const TanStackRouterDevtools =
  process.env.NODE_ENV === "production"
    ? () => null // Render nothing in production
    : React.lazy(() =>
        // Lazy load in development
        import("@tanstack/router-devtools").then((res) => ({
          default: res.TanStackRouterDevtools,
        }))
      );

const Root = () => {
  const { isAuthed } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    if (!isAuthed() && location.pathname !== "/auth/login") {
      navigate({ to: "/auth/login", search: { redirect: location.pathname } });
    }
  }, [isAuthed, navigate]);

  return (
    <>
      <Outlet />
      <TanStackRouterDevtools />
    </>
  );
};

export const Route = createRootRoute({
  component: Root,
});
