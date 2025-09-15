import { ref, computed } from "vue";
import http from "@/api/http";

export const accessToken = ref<string | null>(
  localStorage.getItem("access_token")
);

export function setAccessToken(token: string | null) {
  accessToken.value = token;
  if (token) localStorage.setItem("access_token", token);
  else localStorage.removeItem("access_token");
}

window.addEventListener("storage", (e) => {
  if (e.key === "access_token") setAccessToken(e.newValue);
});

export function useAuth() {
  const isAuthenticated = computed(() => !!accessToken.value);

  async function login(email: string, password: string) {
    const { data } = await http.post("/auth/login", { email, password });
    setAccessToken(data.access_token);
  }

  async function logout() {
    try {
      await http.post("/auth/logout");
    } catch {}
    setAccessToken(null);
  }

  async function refreshAccess() {
    const { data } = await http.post("/auth/refresh");
    setAccessToken(data.access_token);
    return data.access_token as string;
  }

  return {
    accessToken,
    isAuthenticated,
    login,
    logout,
    refreshAccess,
    setAccessToken,
  };
}
