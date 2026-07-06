# TO-DO

## WIP branch — `run-once-after-clone-github-repos`

**What it does:** Clones all non-archived, non-empty personal GitHub repos and forks to their local directories on first run. Logic is solid: confirms before cloning, skips existing repos, cleans up failed partial clones.

**What's correct:**

- Naming `run_once_after_clone-github-repos.sh` is valid: `run_` + `once_` + `after_` + `<name>` ✓
- `after_` order means it runs after chezmoi applies files, so Homebrew (and `gh`) are already installed ✓
- `set -euo pipefail` ✓
- Proper bash shebang (uses arrays and `read -p`) ✓
- Never modifies existing repos ✓

**Blockers before merging:**

**1. No `machine_type` guard — serious**
The script is not a `.tmpl` and has no conditional, so it runs on **all** machine types. On a work machine it would try to clone your personal repos. It needs either a `.tmpl` extension with:

```bash
{{- if ne .machine_type "personal" }}exit 0{{ end }}
```

or to be renamed to `.sh.tmpl`.

**2. `python3 -c` for JSON parsing — performance issue**
Each field of each repo spawns a `python3` subprocess: with 200 repos × 5 fields = ~1000 subprocess calls. Very slow. Replace with `jq` (which `gh` recommends) or use `gh`'s built-in `--jq` flag:

```bash
gh repo list "${GITHUB_USER}" --limit 200 --json name,isFork,isArchived,isEmpty,sshUrl --jq '.[]'
```

Then parse with `jq` in the loop.

**3. `rm -rf` usage — minor**
Three `rm -rf` calls. `trash` won't be available on a fresh machine, so this is acceptable in context — but it conflicts with your safety convention. Worth a comment like `# trash not guaranteed on new machine` to make the intent explicit.

**Verdict: Not ready to merge.** The `machine_type` guard is a functional bug (wrong machines would run it). The `python3` JSON parsing should be replaced with `jq` for correctness and speed. Both are small changes.
