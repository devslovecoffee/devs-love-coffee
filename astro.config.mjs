import { defineConfig } from "astro/config";
import mdx from "@astrojs/mdx";
import sitemap from "@astrojs/sitemap";
import vercel from "@astrojs/vercel/static";
import robotsTxt from "astro-robots-txt";

// https://astro.build/config
export default defineConfig({
  site: "https://devslovecoffee.com",
  adapter: vercel({
    imagesConfig: {
      sizes: [640, 750, 828, 1080, 1200],
      domains: [],
      minimumCacheTTL: 60,
      formats: ["image/avif", "image/webp"],
    },
    imageService: true,
  }),
  trailingSlash: "never",
  integrations: [
    mdx(),
    sitemap(),
    robotsTxt({
      policy: [
        {
          userAgent: "*",
          disallow: ["/assets/**"],
        },
      ],
    }),
  ],
  redirects: {
    "/bento-layouts-tilt-me": "/blog/bento-layouts-tilt-me",
    "/resend-cube-lookalike-part-3": "/blog/resend-cube-lookalike-part-3",
    "/resend-cube-lookalike-part-2": "/blog/resend-cube-lookalike-part-2",
    "/making-the-resend-cube-from-scratch-using-three-js":
      "/blog/making-the-resend-cube-from-scratch-using-three-js",
    "/projects": "/#index-projects",
    "/about": "/#index-about",
  },
  outDir: "./.vercel/output/static",
});
