# Neovim message buffer

## Goal

Keep Neovim's existing notifications and command-line messages visible while
also appending runtime diagnostics to a persistent scratch buffer named
`*Neovim-Messages*`. The buffer gives the user one place to review startup and
session messages with normal buffer navigation.

## Scope

The recorder initializes at the beginning of `init.lua`, before the plugin
loader runs. It records messages emitted after that point through these Lua
entry points:

- `vim.notify`
- global Lua `print`
- `vim.api.nvim_echo`

Each log entry has a timestamp, a severity/category, and text split into
buffer lines. The original function is always called first, so existing
notifications, command-line output, and plugin behaviour remain unchanged.

On `VimEnter`, the recorder imports the current `:messages` history once. This
covers messages emitted during startup which were not routed through a wrapped
Lua entry point.

## Commands and interaction

- `:OpenMessages` opens the dedicated buffer in a split, reusing it if it is
  already displayed.
- `:ClearMessages` clears recorded entries without deleting the buffer.
- `:MessagesKeylogToggle` enables or disables raw key logging for temporary
  keymap troubleshooting. It is disabled by default.

The buffer uses `buftype=nofile`, `bufhidden=hide`, and `swapfile=false`; it is
not written to disk or offered as a normal file buffer.

## Components

`lua/core/messages.lua` owns buffer creation, formatting, appending, wrappers,
the one-time `:messages` import, and the commands. `init.lua` only requires
this module before configuring the plugin runtime.

The module keeps an append-in-progress guard so logging cannot recursively
trigger itself. It does not change `:messages` or replace Neovim's native
message UI.

## Error handling and limits

The wrapper preserves the original functions' signatures and return values.
Failures to append are suppressed to avoid a logging failure causing a startup
failure.

Messages produced before `init.lua` executes cannot be captured in a Lua
buffer (for example, an invalid `init.lua` syntax error or a runtime-loading
failure). Native messages emitted outside the wrapped Lua APIs are only
available through the one-time `:messages` import, not guaranteed live.

Raw key logging records physical key input and can grow quickly, so it remains
opt-in and the normal message recorder stays lightweight.

## Verification

An isolated headless startup test will verify that the buffer and commands are
created. A Lua test script will invoke `vim.notify`, `print`, and `nvim_echo`,
then assert that their text is present in the buffer while the original output
paths still execute. The test will also verify key logging is disabled by
default and records input only after it is toggled on.
