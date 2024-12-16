import { createFileRoute } from "@tanstack/react-router";
import LoginForm from "@/features/auth/login-form";

type LoginSearch = {
  redirect: string;
};

export const Route = createFileRoute("/auth/login")({
  component: Login,
  validateSearch: (search: Record<string, unknown>): LoginSearch => {
    return {
      redirect: (search.redirect as string) || "/",
    };
  },
});

function Login() {  
    const {redirect} = Route.useSearch()
    return (
      <div className="flex items-center justify-center min-h-screen bg-gray-100">
      <div className="w-full max-w-md">
        <h1 className="mb-6 text-3xl font-bold text-center">Login</h1>
        <LoginForm redirect={redirect}/>
      </div>
    </div>
    )
}
