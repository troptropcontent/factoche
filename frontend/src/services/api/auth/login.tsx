import { AxiosInstance } from "axios"

const login = (client: AxiosInstance) => {
    return async (data: {username: string, password: string}): Promise<{accessToken: string, refreshToken: string}> => {
        const response = await client.post("/auth/login", data)
        return response.data
    }
}

export {login}