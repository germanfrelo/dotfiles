import { execFileSync, spawnSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { join } from "node:path";

const repoRoot = new URL("../", import.meta.url).pathname;

// Read managed files from the git index (staged + committed), not from disk.
// This ensures MANAGED.txt reflects exactly what is (or will be) committed,
// immune to uncommitted source files that would otherwise pollute the output.
const gitOutput = execFileSync("git", ["ls-files", "--cached", "home/"], {
	encoding: "utf8",
});

const allPaths = gitOutput.trim().split("\n").filter(Boolean);

const targetPaths = allPaths
	.filter((p) => !isChezmoiMetaFile(p) && !isRemoveFile(p))
	.map(sourcePathToTarget)
	.join("\n");

const result = spawnSync("tree", ["-a", "--fromfile", "."], {
	input: targetPaths,
	encoding: "utf8",
});
process.stdout.write(result.stdout);

const removePaths = allPaths.filter(isRemoveFile).sort();
if (removePaths.length > 0) {
	process.stdout.write("\n## Enforced absent\n\n");
	for (const sourcePath of removePaths) {
		const targetPath = sourcePathToTarget(sourcePath);
		const content = readFileSync(join(repoRoot, sourcePath), "utf8").trim();
		const adrRef = content.startsWith("adr:") ? content.slice(4).trim() : null;
		const adrSuffix = adrRef ? ` — [ADR](${adrRef})` : "";
		process.stdout.write(`- \`~/${targetPath}\`${adrSuffix}\n`);
	}
}

function isChezmoiMetaFile(path) {
	const first = path.slice("home/".length).split("/")[0];
	// Top-level chezmoi config files (.chezmoiscripts/ is NOT excluded — it appears in the tree)
	return first === ".chezmoi.toml.tmpl" || first === ".chezmoiignore";
}

function isRemoveFile(path) {
	const parts = path.slice("home/".length).split("/");
	return parts[parts.length - 1].startsWith("remove_");
}

function sourcePathToTarget(path) {
	const parts = path.slice("home/".length).split("/");
	return parts.map(chezmoiNameToTarget).join("/");
}

function chezmoiNameToTarget(name) {
	const attributePrefixes = [
		"private_",
		"readonly_",
		"executable_",
		"encrypted_",
		"exact_",
		"create_",
		"modify_",
		"symlink_",
		"run_",
		"once_",
		"onchange_",
		"before_",
		"after_",
		"remove_",
		"literal_",
		"empty_",
	];
	let stripped = true;
	while (stripped) {
		stripped = false;
		for (const prefix of attributePrefixes) {
			if (name.startsWith(prefix)) {
				name = name.slice(prefix.length);
				stripped = true;
				break;
			}
		}
	}
	if (name.startsWith("dot_")) {
		name = "." + name.slice(4);
	}
	if (name.endsWith(".tmpl")) {
		name = name.slice(0, -5);
	}
	return name;
}
