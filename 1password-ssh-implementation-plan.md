# Implementation Plan: 1Password SSH Agent & Git Authentication

This implementation plan preserves the deferred SSH & 1Password documentation work following the repository cloning bootstrap release.

---

## 1. Objectives

- Formalize the architecture and decision record for Git network transport and commit signing via the 1Password SSH Agent on macOS.
- Update documentation to reflect the latest official 1Password Developer documentation.
- Add illustrative screenshots of 1Password desktop configuration where beneficial.
- Document and cement the configuration in [`home/private_dot_ssh/private_config`](/home/private_dot_ssh/private_config).

---

## 2. Deferred Content: The Authentication Chain

The following 7-step sequence was extracted from ADR 0007 and deferred to this dedicated workstream:

1. **Invocation:** `gh repo clone <owner>/<repo>` invokes the system `git clone git@github.com:<owner>/<repo>.git`.
2. **Transport protocol:** `git` delegates SSH transport to the OpenSSH client (`ssh`).
3. **Configuration bridge:** OpenSSH reads [`~/.ssh/config`](/home/private_dot_ssh/private_config), which defines `IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"`.
4. **Agent socket resolution:** OpenSSH forwards the public key challenge across the macOS App Group socket (`2BUA8C4S2C.com.1password`) to the unlocked 1Password desktop process.
5. **Key authorization:** 1Password supplies the cryptographic challenge response using the stored SSH authentication key (prompting via Touch ID if authorization has expired).
6. **Separation of keys:** The SSH authentication key is strictly reserved for network transport (SSH sessions, clone, push), whereas the SSH signing key is configured separately in [`.gitconfig`](/home/private_dot_config/private_git/private_config.tmpl) solely for cryptographic commit signing (`gpgsign = true`).
7. **Transport vs signing independence:** Git commit signing is executed entirely locally via the 1Password agent socket, independent of the remote repository URL (HTTPS or SSH). Switching the dotfiles repository remote to SSH allows network operations (`git push`, `git fetch`) to authenticate through 1Password and the SSH authentication key consistently with all other repositories.

---

## 3. Workstream Steps

### Step 1: Decision Record (ADR 0008)

- Create `docs/decisions/0008-git-authentication-1password-ssh-agent.md` following the MADR template.
- Document the decision drivers: biometric authorization via Touch ID, private keys never touching disk unencrypted, separation between transport auth key and commit signing key.
- Incorporate the full authentication chain above.
- Cross-link with [ADR 0007](/docs/decisions/0007-personal-github-repositories-cloning.md).

### Step 2: Documentation Audit against Current 1Password Docs

- Review [1Password SSH Agent Documentation](https://developer.1password.com/docs/ssh/agent/) for any recent macOS changes (e.g., socket paths, configuration options, Touch ID timeout settings).
- Audit [1Password Git Commit Signing](https://developer.1password.com/docs/ssh/git-commit-signing/) against [`home/private_dot_config/private_git/private_config.tmpl`](/home/private_dot_config/private_git/private_config.tmpl).

### Step 3: Visual Assets (Screenshots)

- Capture screenshots of 1Password desktop application:
  - **Settings → Developer:** "Use the SSH Agent" toggle enabled.
  - Authorized keys view (displaying separate auth and signing keys).
- Determine storage location for images (e.g., `docs/assets/` or repository documentation folder).
- Integrate screenshots into documentation or ADR.

### Step 4: Finalize SSH Config Comments

- In [`home/private_dot_ssh/private_config`](/home/private_dot_ssh/private_config), review and commit the explanatory comments:
  - Local include escape hatch (`Include ~/.ssh/config.local`).
  - 1Password agent socket reference and documentation link.
