#!/usr/bin/env bash
# run_once_after_clone-github-repos.sh
# =====================================
# Clones all non-archived, non-empty personal GitHub repos and forks to their
# local directories. Runs once on a new machine via chezmoi.
#
# Directories:
#   Personal repos: ~/repos/germanfrelo/
#   Forks:          ~/repos/forks/
#
# Safety rules:
#   - NEVER modifies existing repos (no pull, no reset, no force).
#   - Skips archived repos.
#   - Skips the 'test' repo (empty, no commits).
#   - If a directory already exists but is not a git repo: asks interactively.
#   - If a directory exists with a different remote URL: asks interactively.
#   - Partial clones (clone failed mid-way): cleaned up automatically.

set -euo pipefail

GITHUB_USER="germanfrelo"
PERSONAL_DIR="${HOME}/repos/germanfrelo"
FORKS_DIR="${HOME}/repos/forks"

# Repos to skip even if not archived (e.g. empty repos with no commits).
SKIP_REPOS=("test")

# ── Helpers ───────────────────────────────────────────────────────────────────

ask_yes_no() {
    local prompt="$1"
    local reply
    while true; do
        read -rp "${prompt} [y/N] " reply
        case "${reply}" in
            [Yy]) return 0 ;;
            [Nn]|"") return 1 ;;
            *) echo "  Please answer y or n." ;;
        esac
    done
}

is_in_skip_list() {
    local repo="$1"
    for skip in "${SKIP_REPOS[@]}"; do
        [[ "${repo}" == "${skip}" ]] && return 0
    done
    return 1
}

clone_repo() {
    local name="$1"
    local ssh_url="$2"
    local target_dir="$3"

    # Already exists?
    if [[ -d "${target_dir}" ]]; then
        if [[ ! -d "${target_dir}/.git" ]]; then
            echo "  ⚠  ${name}: directory exists but is not a git repo (${target_dir})"
            if ask_yes_no "     Delete and clone fresh?"; then
                rm -rf "${target_dir}"
            else
                echo "     Skipping."
                return
            fi
        else
            # It's a git repo — check remote URL.
            local current_remote
            current_remote=$(git -C "${target_dir}" remote get-url origin 2>/dev/null || echo "")
            if [[ "${current_remote}" != "${ssh_url}" ]]; then
                echo "  ⚠  ${name}: remote URL mismatch"
                echo "     Expected : ${ssh_url}"
                echo "     Found    : ${current_remote}"
                if ask_yes_no "     Delete and re-clone from expected URL?"; then
                    rm -rf "${target_dir}"
                else
                    echo "     Skipping."
                    return
                fi
            else
                echo "  ✓ ${name}: already cloned — skipping"
                return
            fi
        fi
    fi

    # Clone.
    echo "  ↓ ${name}: cloning…"
    if git clone "${ssh_url}" "${target_dir}"; then
        echo "    ✓ done"
    else
        echo "    ✗ clone failed — cleaning up partial directory"
        rm -rf "${target_dir}"
    fi
}

# ── Fetch repo list from GitHub API ───────────────────────────────────────────

if ! command -v gh &>/dev/null; then
    echo "ERROR: gh CLI not found. Install it (brew install gh) and authenticate (gh auth login) first."
    exit 1
fi

echo "Fetching repos for ${GITHUB_USER}…"

# gh repo list returns all repos (personal + forks). We split by fork status.
# --limit 200 is generous; adjust if the account grows significantly.
repos_json=$(gh repo list "${GITHUB_USER}" \
    --limit 200 \
    --json name,isFork,isArchived,isEmpty,sshUrl \
    2>/dev/null)

# ── Confirmation prompt ───────────────────────────────────────────────────────
echo ""
echo "Target directories:"
echo "  Personal: ${PERSONAL_DIR}"
echo "  Forks:    ${FORKS_DIR}"
echo ""
if ! ask_yes_no "Clone all repos for ${GITHUB_USER}? (archived/empty repos are skipped)"; then
    echo "Aborted."
    exit 0
fi

mkdir -p "${PERSONAL_DIR}" "${FORKS_DIR}"

echo ""
echo "── Personal repos ───────────────────────────────────────────────────────"
while IFS= read -r repo_json; do
    name=$(echo "${repo_json}" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['name'])")
    is_fork=$(echo "${repo_json}" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['isFork'])")
    is_archived=$(echo "${repo_json}" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['isArchived'])")
    is_empty=$(echo "${repo_json}" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['isEmpty'])")
    ssh_url=$(echo "${repo_json}" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['sshUrl'])")

    [[ "${is_fork}" == "True" ]] && continue

    if [[ "${is_archived}" == "True" ]]; then
        echo "  ⊘ ${name}: archived — skipping"
        continue
    fi
    if [[ "${is_empty}" == "True" ]] || is_in_skip_list "${name}"; then
        echo "  ⊘ ${name}: empty or in skip list — skipping"
        continue
    fi

    clone_repo "${name}" "${ssh_url}" "${PERSONAL_DIR}/${name}"
done < <(echo "${repos_json}" | python3 -c "
import sys, json
for item in json.load(sys.stdin):
    import json as j
    print(j.dumps(item))
")

echo ""
echo "── Forks ─────────────────────────────────────────────────────────────────"
while IFS= read -r repo_json; do
    name=$(echo "${repo_json}" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['name'])")
    is_fork=$(echo "${repo_json}" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['isFork'])")
    is_archived=$(echo "${repo_json}" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['isArchived'])")
    is_empty=$(echo "${repo_json}" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['isEmpty'])")
    ssh_url=$(echo "${repo_json}" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['sshUrl'])")

    [[ "${is_fork}" == "False" ]] && continue

    if [[ "${is_archived}" == "True" ]]; then
        echo "  ⊘ ${name}: archived — skipping"
        continue
    fi
    if [[ "${is_empty}" == "True" ]]; then
        echo "  ⊘ ${name}: empty — skipping"
        continue
    fi

    clone_repo "${name}" "${ssh_url}" "${FORKS_DIR}/${name}"
done < <(echo "${repos_json}" | python3 -c "
import sys, json
for item in json.load(sys.stdin):
    import json as j
    print(j.dumps(item))
")

echo ""
echo "Done."
