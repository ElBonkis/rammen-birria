import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";
import { fileURLToPath, URL } from "node:url";

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: { "@": fileURLToPath(new URL("./src", import.meta.url)) },
  },
  server: {
    host: true,
    port: 5173,
    proxy: {
      "/api": {
        target: process.env.VITE_PROXY_TARGET || "http://backend:3000",
        changeOrigin: true,
        secure: false,
      },
      "/rails": {
      target: process.env.VITE_PROXY_TARGET || "http://backend:3000",
      changeOrigin: true,
      secure: false,
    },
    },
  },
});
