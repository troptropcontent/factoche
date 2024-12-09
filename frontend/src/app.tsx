import { StrictMode } from "react";
import { RouterProvider, createRouter } from "@tanstack/react-router";

// Import the generated route tree
import { routeTree } from "./routeTree.gen";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { AuthContextProvider } from "./contexts/auth_context";

// Create a new router instance
const router = createRouter({ routeTree });

// Register the router instance for type safety
declare module "@tanstack/react-router" {
  interface Register {
    router: typeof router;
  }
}

const queryClient = new QueryClient();

const App = () => {
  return (
    <StrictMode>
      <QueryClientProvider client={queryClient}>
        <AuthContextProvider>
          <RouterProvider router={router} />
        </AuthContextProvider>
      </QueryClientProvider>
    </StrictMode>
  );
};

export { App };
