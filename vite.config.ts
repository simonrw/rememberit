import { defineConfig } from "vite";
import { VitePWA } from "vite-plugin-pwa";
import react from "@vitejs/plugin-react";
import path from "path";

const vitePWA = VitePWA({
  manifest: {
    name: "RememberIt",
    short_name: "RememberIt",
    start_url: "/",
    background_color: "#1f2937",
    theme_color: "#4b5563",
    icons: [
      {
        src: "icons/remembering.png",
        sizes: "512x512",
        type: "image/png",
      },
    ],
    display: "standalone",
  },
  devOptions: {
    enabled: true,
  },
});

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react(), vitePWA],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
});
