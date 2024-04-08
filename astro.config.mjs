import { defineConfig } from 'astro/config';
import mdx from '@astrojs/mdx';
import sitemap from '@astrojs/sitemap';

import robotsTxt from "astro-robots-txt";

// https://astro.build/config
export default defineConfig({
  	site: 'https://devslovecoffee.com',
	trailingSlash: 'never',
  	integrations: [
		mdx(),
		sitemap(),
		robotsTxt({
			policy: [{
				userAgent: '*',
				disallow: [
					'/assets/resend_cube.html',
					'/assets/resend_cube_2.html',
					'/assets/resend_cube_3.html',
					'/assets/index-basic.html',
					'/assets/index-advanced.html',
				]
			}]
		})
	],
	redirects: {
		'/bento-layouts-tilt-me': '/blog/bento-layouts-tilt-me',
		'/resend-cube-lookalike-part-3': '/blog/resend-cube-lookalike-part-3',
		'/resend-cube-lookalike-part-2': '/blog/resend-cube-lookalike-part-2',
		'/making-the-resend-cube-from-scratch-using-three-js': '/blog/making-the-resend-cube-from-scratch-using-three-js',
		'/projects': '/about'
  	},
	outDir: './.vercel/output/static',
});