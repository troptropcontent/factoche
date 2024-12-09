import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { useAuth } from "../../hooks/use_auth";
import { useLoginMutation } from "../../queries/auth/useLoginMutation";

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
    const {login} = useAuth()
    const navigate = useNavigate()
    const search = Route.useSearch()
    const loginMutation = useLoginMutation()
    
    return (
      <div>
        <div>
          <h2>Sign in to your account</h2>
          <form
            onSubmit={async (e) => {
              e.preventDefault();
              const formData = new FormData(e.currentTarget);
              const username = formData.get("username") as string;
              const password = formData.get("password") as string;
              
              loginMutation.mutate({username, password}, {onSuccess: ({accessToken, refreshToken}) => {
                login(accessToken, refreshToken)
                navigate({to: search.redirect})
              }})
            }}
          >
            <div>
              <label htmlFor="username">
                Username
              </label>
              <input
                id="username"
                name="username"
                type="text"
                required
              />
            </div>
            <div>
              <label htmlFor="password">
                Password
              </label>
              <input
                id="password"
                name="password"
                type="password"
                required
              />
            </div>
            <button
              type="submit"
            >
              Sign in
            </button>
          </form>
        </div>
      </div>
    )
}
