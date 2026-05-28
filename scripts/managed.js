import { execFileSync, spawnSync } from "node:child_process";
import { readdirSync, readFileSync } from "node:fs";
import { join, relative } from "node:path";

const sourceRoot = new URL("../home", import.meta.url).pathname;

const managed = execFileSync("chezmoi", ["managed", "--exclude=remove"], {
	encoding: "utf8",
});
const result = spawnSync("tree", ["-a", "--fromfile", "."], {
	input: managed,
	encoding: "utf8",
});
process.stdout.write(result.stdout);

const removeFiles = findRemoveFiles(sourceRoot).sort();
if (removeFiles.length > 0) {
	process.stdout.write("\n## Enforced absent\n\n");
	for (const filePath of removeFiles) {
		const targetPath = chezmoiSourceToTargetPath(filePath, sourceRoot);
		const content = readFileSync(filePath, "utf8").trim();
		const adrRef = content.startsWith("adr:") ? content.slice(4).trim() : null;
		const adrSuffix = adrRef ? ` — [ADR](${adrRef})` : "";
		process.stdout.write(`- \`${targetPath}\`${adrSuffix}\n`);
	}
}

function findRemoveFiles(dir, results = []) {
	for (const entry of readdirSync(dir, { withFileTypes: true })) {
		const fullPath = join(dir, entry.name);
		if (entry.isDirectory()) {
			findRemoveFiles(fullPath, results);
		} else if (entry.name.startsWith("remove_")) {
			results.push(fullPath);
		}
	}
	return results;
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

function chezmoiSourceToTargetPath(sourcePath, root) {
	const rel = relative(root, sourcePath);
	const components = rel.split("/").map(chezmoiNameToTarget);
	return "~/" + components.join("/");
}
