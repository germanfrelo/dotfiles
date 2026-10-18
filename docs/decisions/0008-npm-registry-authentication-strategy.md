---
status: accepted
date: 2026-10-18
---

# npm Registry Authentication Strategy

## Context and Problem Statement

In this repository, user-level npm configuration is managed by chezmoi via `home/private_dot_npmrc` (targeting `~/.npmrc`), which currently enforces `save-exact = true`.

When publishing packages to the public npm registry (`registry.npmjs.org`) or installing from private scoped registries, the npm CLI requires authentication.

By default, the standard `npm login` CLI command appends an unencrypted authentication token directly to the user's `~/.npmrc` file:

```ini
//registry.npmjs.org/:_authToken=npm_xxxxxxxxxxxxxxxxxxxx
```

Storing raw authentication tokens directly in `~/.npmrc` creates a severe conflict with chezmoi:

1. Running `chezmoi apply` detects local modifications to `~/.npmrc` as drift and overwrites the file, destroying the active login token.
2. Running `chezmoi re-add` copies the unencrypted authentication token into the dotfiles source repository, creating an unacceptable secret leak risk to Git.

How should npm registry authentication tokens be managed across macOS machines in a chezmoi-managed dotfiles repository without leaking credentials to Git or losing authentication state upon `chezmoi apply`?

## Decision Drivers

- **Zero secrets in Git**: Prevent plaintext authentication tokens from entering the dotfiles Git repository.
- **Chezmoi apply idempotence**: Allow running `chezmoi apply` at any time without destroying active npm authentication sessions.
- **Single Source of Truth**: Leverage 1Password (the repository's canonical secrets manager) rather than creating separate ad-hoc credential stores.
- **Native toolchain compatibility**: Ensure standard commands (`npm publish`, `npm install`, `npx`) operate seamlessly without requiring custom wrapper scripts.
- **Minimal attack surface**: Avoid persisting long-lived plaintext bearer tokens in static filesystem configuration files.

## Considered Options

- **Option 1**: Dynamic shell environment variable (`$NPM_TOKEN`) via 1Password CLI / 1Password shell plugin.
- **Option 2**: Chezmoi template for `~/.npmrc` (`private_dot_npmrc.tmpl`) using `onepasswordRead`.
- **Option 3**: Per-project `.npmrc` files with manual `.gitignore` entries.
- **Option 4**: Interactive `npm login` writing directly to `~/.npmrc` (Default / Anti-pattern).

## Decision Outcome

Chosen option: **Option 1 (Dynamic shell environment variable `$NPM_TOKEN` via 1Password CLI / 1Password shell plugin)**, because it completely decouples secret storage from the filesystem, preserves `~/.npmrc` as a clean, static configuration file, and eliminates any possibility of chezmoi overwrite conflicts or Git secret leaks.

Under this architecture:

1. `~/.npmrc` remains managed by chezmoi as a static file containing non-sensitive preferences (`save-exact = true`).
2. The npm publishing token is stored securely in a 1Password vault item (e.g. `op://personal/npm/token`).
3. Authentication is provided to the npm CLI dynamically via one of two 1Password mechanisms:
   - **1Password Shell Plugin (Recommended)**: Configuring `op plugin init npm`, which aliases or wraps `npm` to dynamically provision session credentials via biometric authorization (Touch ID).
   - **Environment variable fallback**: Sourcing `export NPM_TOKEN="$(op read "op://personal/npm/token")"` in shell sessions or passing it inline during publishing: `env NPM_TOKEN="$(op read ...)" npm publish`.
4. In `~/.npmrc`, reference the token via standard npm environment variable interpolation:

   ```ini
   //registry.npmjs.org/:_authToken=${NPM_TOKEN}
   ```

### Consequences

- Good, because `home/private_dot_npmrc` remains 100% free of plaintext secrets and safe to track in Git.
- Good, because `chezmoi apply` is idempotent and safe to run at any time without terminating login sessions.
- Good, because tokens are not persisted in plaintext on disk, reducing exposure to unauthorized local processes.
- Good, because 1Password biometric authorization (Touch ID) gates publishing operations.
- Bad, because publishing requires 1Password CLI (`op`) to be authenticated and available on the machine.

### Confirmation

Compliance with this decision is confirmed when:

1. `chezmoi status ~/.npmrc` remains clean (` `) before and after running npm authentication or publishing tasks.
2. `git grep -i "_authtoken" home/` returns zero matches across the entire dotfiles repository.
3. Running `npm whoami` in a shell with `op` authenticated successfully returns the authenticated npm username.

## Pros and Cons of the Options

### Option 1: Dynamic Shell Environment Variable via 1Password (Chosen)

Manage credentials in 1Password and expose them to npm via environment variable interpolation (`${NPM_TOKEN}`) or the 1Password shell plugin.

- Good, because `~/.npmrc` remains static, clean, and safe in chezmoi.
- Good, because `chezmoi apply` can never overwrite or invalidate active login credentials.
- Good, because it leverages 1Password biometric authentication.
- Bad, because it requires the 1Password CLI to be installed and unlocked.

### Option 2: Chezmoi Template for `~/.npmrc` (`private_dot_npmrc.tmpl`)

Convert `home/private_dot_npmrc` into a Go template using `{{ onepasswordRead "op://personal/npm/token" }}` to render the token into `~/.npmrc` on `chezmoi apply`.

- Good, because `npm` does not require special environment variables or shell plugins to function.
- Neutral, because chezmoi handles secret retrieval at apply time.
- Bad, because it writes an unencrypted bearer token onto the local filesystem in plaintext.
- Bad, because `chezmoi diff` and `chezmoi apply` will hang or prompt for 1Password biometric authentication every time `~/.npmrc` is evaluated.

### Option 3: Per-Project `.npmrc` Files

Keep global `~/.npmrc` unauthenticated and place `_authToken` only in individual project repositories, relying on `.gitignore` to prevent commits.

- Good, because global `~/.npmrc` is unaffected by credentials.
- Bad, because high risk of developer error accidentally committing `.npmrc` to a project repository.
- Bad, because credentials must be duplicated across multiple local project directories.

### Option 4: Interactive `npm login` to `~/.npmrc` (Default / Anti-pattern)

Allow `npm login` to write `_authToken` directly to `~/.npmrc`.

- Good, because it requires zero custom setup.
- Bad, because `chezmoi apply` will silently overwrite `~/.npmrc`, destroying the login token.
- Bad, because running `chezmoi re-add` will commit a plaintext secret token to Git.

## More Information

- [npm CLI documentation on `npmrc`](https://docs.npmjs.com/cli/configuring-npm/npmrc)
- [npm CLI documentation on `npm login`](https://docs.npmjs.com/cli/commands/npm-login)
- [1Password Shell Plugins for npm](https://developer.1password.com/docs/cli/shell-plugins/npm/)
- [ADR 0004: Reject chezmoi symlink approach for external configs](/docs/decisions/0004-reject-chezmoi-symlink-approach-for-external-configs.md)
