import { ACCESS_TOKEN_KEY } from "./auth-constants";

const getAccessToken = () => localStorage.getItem(ACCESS_TOKEN_KEY);
const clearAccessToken = () => localStorage.removeItem(ACCESS_TOKEN_KEY);

export { getAccessToken, clearAccessToken };
