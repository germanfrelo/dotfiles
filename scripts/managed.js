import { execFileSync, spawnSync } from "node:child_process";

const managed = execFileSync("chezmoi", ["managed"], { encoding: "utf8" });
const result = spawnSync("tree", ["-a", "--fromfile", "."], {
	input: managed,
	encoding: "utf8",
});
process.stdout.write(result.stdout);
