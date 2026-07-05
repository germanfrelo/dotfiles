// prettier.config.js, .prettierrc.js, prettier.config.mjs, or .prettierrc.mjs

/**
 * @see https://prettier.io/docs/en/configuration.html
 * @type {import("prettier").Config}
 */
const config = {
	quoteProps: "consistent",
	overrides: [
		{
			files: ["*.js", "*.jsx", "*.vue"],
			options: {
				singleAttributePerLine: true,
			},
		},
		{
			files: ["*.jsonc"],
			options: {
				trailingComma: "none",
			},
		},
		{
			files: ["home/dot_gemini/**/*.json"],
			options: {
				useTabs: false,
			},
		},
	],
};

export default config;
