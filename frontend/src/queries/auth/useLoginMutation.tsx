import { useMutation } from "@tanstack/react-query"
import { useApiClient } from "../../hooks/use_api_client"
import { login } from "../../services/api/auth/login"

const useLoginMutation = () => {
    const apiClient = useApiClient()
    const loginFn = login(apiClient)
    return useMutation({
        mutationFn: (data: {username: string, password: string}) => loginFn(data),
    })
}

export {useLoginMutation}