import { createLazyFileRoute } from "@tanstack/react-router";
import { useAuth } from "../hooks/use_auth";
import { Button } from "@/components/ui/button";
import { Layout } from "@/components/layout/layout";

export const Route = createLazyFileRoute("/")({
  component: Index,
});

function Index() {
  const { logout } = useAuth();
  return (
    <Layout>
      <div>
        <h1 className="text-sky-700">Hello from Home!</h1>
        <Button
          onClick={() => {
            logout();
          }}
        >
          Logout
        </Button>
      </div>
    </Layout>
  );
}
