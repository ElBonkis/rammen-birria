import axios, { AxiosError, AxiosRequestConfig } from "axios";
import { ref, computed } from "vue";

const ACCESS_KEY = "auth.access";

export const accessToken = ref<string | null>(localStorage.getItem(ACCESS_KEY));
export const isAuthenticated = computed(() => !!accessToken.value);

export function getAccessToken(): string | null {
  return accessToken.value;
}
export function setAccessToken(token: string | null) {
  accessToken.value = token;
  if (token) localStorage.setItem(ACCESS_KEY, token);
  else localStorage.removeItem(ACCESS_KEY);
  window.dispatchEvent(new CustomEvent("auth:token-changed", { detail: token }));
}
export function clearAccessToken() {
  setAccessToken(null);
}

window.addEventListener("storage", (e) => {
  if (e.key === ACCESS_KEY) setAccessToken(e.newValue);
});

const ENV_BASE = (import.meta.env.VITE_API_BASE_URL || "").trim();
const baseURL = /^https?:\/\//i.test(ENV_BASE) ? ENV_BASE : "http://localhost:3000";
if (!/^https?:\/\//i.test(ENV_BASE)) {
  console.warn("[http] VITE_API_BASE_URL no definido o inválido; usando", baseURL);
}

const http = axios.create({
  baseURL: "/api",
  withCredentials: true, 
});

http.interceptors.request.use((config) => {
  const access = accessToken.value;
  if (access) {
    config.headers = config.headers ?? {};
    (config.headers as any)["Authorization"] = `Bearer ${access}`;
  }
  return config;
});


let isRefreshing = false;
let queue: Array<(t: string | null) => void> = [];

export async function refreshAccess(): Promise<string | null> {
  try {
    const { data } = await http.post<{ access_token: string }>("/auth/refresh");
    const token = data?.access_token ?? null;
    setAccessToken(token);
    return token;
  } catch {
    setAccessToken(null);
    return null;
  }
}

http.interceptors.response.use(
  (r) => r,
  async (error: AxiosError) => {
    const original = error.config as (AxiosRequestConfig & { _retry?: boolean }) | undefined;

    if (error.response?.status === 401 && original && !original._retry) {
      if (isRefreshing) {
        return new Promise((resolve, reject) => {
          queue.push((t) => {
            if (!t) return reject(error);
            original.headers = original.headers ?? {};
            (original.headers as any)["Authorization"] = `Bearer ${t}`;
            (original as any)._retry = true;
            resolve(http(original));
          });
        });
      }

      (original as any)._retry = true;
      isRefreshing = true;
      const newToken = await refreshAccess();
      isRefreshing = false;

      queue.splice(0).forEach((cb) => cb(newToken));

      if (!newToken) throw error;

      original.headers = original.headers ?? {};
      (original.headers as any)["Authorization"] = `Bearer ${newToken}`;
      return http(original);
    }

    throw error;
  }
);

export async function logout(): Promise<void> {
  try {
    await http.post("/auth/logout");
  } catch {
    // no-op
  } finally {
    setAccessToken(null);
  }
}

export default http;
