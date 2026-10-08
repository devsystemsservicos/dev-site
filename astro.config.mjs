// @ts-check
import { defineConfig } from "astro/config";

import cloudflare from "@astrojs/cloudflare";

// Domain is a placeholder from the brand mockup — update before deploy.
export default defineConfig({
  site: "https://www.dev.co.mz",
  trailingSlash: "never",

  build: {
    inlineStylesheets: "auto",
  },

  dev: {
    port: 4321,
  },

  adapter: cloudflare()
});