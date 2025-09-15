import { defineStore } from "pinia";
import http, { setAccessToken } from "@/api/http";

export const useAuth = defineStore("auth", {
  state: () => ({
    token: null as string | null,
    user: null as null | { id: number; email: string },
  }),
  actions: {
    async login(email: string, password: string) {
      const { data } = await http.post("/auth/login", { email, password });
      this.token = data.access_token; setAccessToken(this.token);
      await this.fetchMe();
    },
    async register(email: string, password: string) {
      await http.post("/auth/register", {
        email, password, password_confirmation: password
      });
    },

    async requestPasswordReset(email: string) {
      await http.post("/auth/password/forgot", { email });
    },

    async resetPassword(email: string, token: string, password: string, password_confirmation: string) {
      await http.post("/auth/password/reset", { email, token, password, password_confirmation });
    },

    async refresh() {
      const { data } = await http.post("/auth/refresh");
      this.token = data.access_token; setAccessToken(this.token);
    },
    async fetchMe() {
      await http.get("/products");
      this.user = { id: 1, email: "admin@demo.com" };
    },
    async logout() {
      try { await http.delete("/auth/logout"); } catch {}
      this.token = null; this.user = null; setAccessToken(null);
    },
  },
});
