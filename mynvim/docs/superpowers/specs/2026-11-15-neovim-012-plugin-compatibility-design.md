# Neovim 0.12 plugin compatibility

## Goal

Upgrade every clean plugin repository in `reps/` to a revision compatible with
Neovim 0.12.6 while preserving the current configuration's enabled features.
Keep the configuration reproducible with a Lazy lockfile and leave plugins
with local modifications untouched.

## Scope and safety

The active configuration is the `mynvim` repository, symlinked at
`/Users/bgm/.config/nvim`. Plugin repositories live directly under `reps/`.
Before any update, create a manifest containing every repository's path,
branch, HEAD revision, remote URL, and dirty state. The manifest provides the
exact revisions required for rollback.

Repositories with local changes are not reset, stashed, or updated. They are
reported as skipped so user changes remain intact. All clean repositories are
updated from their configured upstream branch; a repository without an
upstream is reported rather than guessed.

## Compatibility changes

- Replace the obsolete `hop.nvim` repository with its maintained upstream
  version when the updated repository supports Neovim 0.12 health APIs.
- Upgrade `mason.nvim`, `mason-lspconfig.nvim`, `nvim-lspconfig`,
  `nvim-treesitter`, and all other clean installed plugin repositories through
  Lazy's update mechanism or an equivalent fast-forward update.
- Preserve plugin declarations and mappings. Adapt configuration only where an
  upstream API change makes startup fail.
- Replace local deprecated APIs: `vim.lsp.get_active_clients()` with
  `vim.lsp.get_clients()` and `vim.tbl_islist()` with `vim.islist()`.
- Update or configure `nvim-hlslens` only as needed to remove a runtime
  incompatibility; do not change its user-facing mappings.

## Reproducibility and rollback

Run Lazy's update in the active configuration so `lazy-lock.json` records the
resolved revisions, then commit the lockfile and configuration changes.
The pre-update manifest is retained under `docs/` but contains no secrets.
If validation fails, restore every updated clean repository to the recorded
HEAD revisions and restore the lockfile before considering an alternative
migration.

## Validation

The upgrade is accepted only if all of the following succeed under Neovim
0.12.6:

1. A normal headless startup completes without plugin configuration errors.
2. `:checkhealth` has no plugin health-check errors caused by obsolete Neovim
   APIs. Optional language providers and intentionally absent external tools
   are reported separately.
3. Lazy loads the configured plugin set without failures.
4. Mason registry and configured LSP integration initialize successfully.
5. Treesitter parser loading succeeds for a representative Lua buffer.

Skipped dirty repositories are explicitly listed in the validation report and
are outside the compatibility guarantee until their local changes are merged
or discarded by the user.
