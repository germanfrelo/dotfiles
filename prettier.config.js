// ========================================
// Prettier configuration
// https://prettier.io/docs/configuration
// ========================================

/** @type {import("prettier").Config} */
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
