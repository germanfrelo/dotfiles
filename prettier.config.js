// prettier.config.js, .prettierrc.js, prettier.config.mjs, or .prettierrc.mjs

/**
 * @see https://prettier.io/docs/en/configuration.html
 * @type {import("prettier").Config}
 */
const config = {
	quoteProps: "consistent",
	plugins: ["prettier-plugin-multiline-arrays"],
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
			files: ["**/*dot_gemini/**/*.json*"],
			options: {
				useTabs: false,
			},
		},
		{
			files: ["**/snippets/*.json"],
			options: {
				multilineArraysWrapThreshold: 0,
			},
		},
	],
};

export default config;
