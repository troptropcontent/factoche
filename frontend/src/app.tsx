import { StrictMode } from "react";
import { RouterProvider, createRouter } from "@tanstack/react-router";

// Import the generated route tree
import { routeTree } from "./routeTree.gen";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import "./app.css";
import { Toaster } from "@/components/ui/toaster";
import { AuthProvider } from "./auth";

// Create a new router instance
const queryClient = new QueryClient();

const router = createRouter({
  routeTree,
  context: {
    queryClient,
    companyId: null,
  },
  defaultPreload: "intent",
  defaultPreloadStaleTime: 0,
});

// Register the router instance for type safety
declare module "@tanstack/react-router" {
  interface Register {
    router: typeof router;
  }
}

const App = () => {
  return (
    <StrictMode>
      <QueryClientProvider client={queryClient}>
        <AuthProvider>
          <RouterProvider router={router} />
        </AuthProvider>
      </QueryClientProvider>
      <Toaster />
    </StrictMode>
  );
};

export { App };
