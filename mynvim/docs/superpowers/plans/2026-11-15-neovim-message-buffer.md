# Neovim Message Buffer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Preserve native Neovim output while recording Lua notifications, prints, and API echoes in a reusable `*Neovim-Messages*` scratch buffer.

**Architecture:** A single early-loaded `core.messages` module owns the buffer, formatting, wrappers, commands, startup snapshot, and optional key logger. It captures messages beside the original output path, uses a re-entrancy guard, and is initialized before plugin loading.

**Tech Stack:** Neovim Lua API, headless Neovim test script, shell test runner.

---

### Task 1: Add a failing headless behaviour test

**Files:**
- Create: `tests/messages_spec.lua`
- Create: `tests/test_messages.sh`

- [ ] **Step 1: Write the failing test**

Create `tests/messages_spec.lua` containing:

```lua
vim.opt.runtimepath:prepend(vim.fn.getcwd())

local messages = require("core.messages")
messages.setup()

local buffer = messages.buffer()
assert(vim.api.nvim_buf_is_valid(buffer), "message buffer was not created")
assert(vim.api.nvim_buf_get_name(buffer):match("%*Neovim%-Messages%*$"), "wrong message buffer name")
assert(vim.bo[buffer].buftype == "nofile", "message buffer must be nofile")
assert(vim.bo[buffer].bufhidden == "hide", "message buffer must be hidden")
assert(vim.bo[buffer].swapfile == false, "message buffer must not use a swapfile")

vim.notify("notify marker", vim.log.levels.ERROR)
print("print marker")
vim.api.nvim_echo({ { "echo marker", "WarningMsg" } }, true, {})

local text = table.concat(vim.api.nvim_buf_get_lines(buffer, 0, -1, false), "\n")
assert(text:find("[ERROR] notify marker", 1, true), "notify message was not recorded")
assert(text:find("[PRINT] print marker", 1, true), "print message was not recorded")
assert(text:find("[ECHO] echo marker", 1, true), "echo message was not recorded")

assert(vim.fn.exists(":OpenMessages") == 2, "OpenMessages command is missing")
assert(vim.fn.exists(":ClearMessages") == 2, "ClearMessages command is missing")
assert(vim.fn.exists(":MessagesKeylogToggle") == 2, "MessagesKeylogToggle command is missing")

vim.cmd("OpenMessages")
assert(vim.api.nvim_get_current_buf() == buffer, "OpenMessages did not display the message buffer")
vim.cmd("ClearMessages")
assert(#vim.api.nvim_buf_get_lines(buffer, 0, -1, false) == 0, "ClearMessages did not empty the buffer")
```

Create `tests/test_messages.sh` containing:

```bash
#!/usr/bin/env bash
set -euo pipefail
test_root=$(cd "$(dirname "$0")/.." && pwd)
cd "$test_root"
XDG_DATA_HOME=$(mktemp -d) XDG_STATE_HOME=$(mktemp -d) XDG_CACHE_HOME=$(mktemp -d) \
  nvim --clean --headless -u NONE -c 'luafile tests/messages_spec.lua' -c 'qa!'
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `bash tests/test_messages.sh`

Expected: FAIL with `module 'core.messages' not found`.

### Task 2: Implement the recorder module

**Files:**
- Create: `lua/core/messages.lua`
- Test: `tests/messages_spec.lua`

- [ ] **Step 1: Implement the smallest module that satisfies the test**

Create `lua/core/messages.lua` with these behaviours:

```lua
local M = {}
local buffer
local appending = false
local key_logging = false
local originals = {}

function M.buffer()
  -- Return the live buffer, creating it on first use.
end

function M.setup()
  -- Be idempotent; create the buffer, install wrappers and commands once.
end
```

`M.buffer()` creates a listed=false, scratch buffer named `*Neovim-Messages*`,
sets `buftype=nofile`, `bufhidden=hide`, `swapfile=false`, and returns its ID.
An internal append helper writes timestamped lines while `appending` is true.

`M.setup()` stores and wraps `vim.notify`, `_G.print`, and `vim.api.nvim_echo`.
Each wrapper calls its stored original function and appends respectively tagged
`[INFO]`/`[WARN]`/`[ERROR]`, `[PRINT]`, or `[ECHO]` text. Flatten `nvim_echo`
chunks before appending. The append guard prevents wrapped output caused by
logging itself from re-entering the recorder.

Define `:OpenMessages` using `sbuffer` with the numeric buffer ID, define
`:ClearMessages` to replace all lines with an empty list, and define
`:MessagesKeylogToggle` to toggle `vim.on_key` logging. The key callback
appends `[KEY] ` plus `vim.fn.keytrans(key)` only when enabled.

Register a once-only `VimEnter` autocmd which appends `vim.fn.execute("messages")`
as `[HISTORY]` lines when non-empty.

- [ ] **Step 2: Run the focused test to verify it passes**

Run: `bash tests/test_messages.sh`

Expected: exit code 0; terminal output can include the preserved `print` and
`nvim_echo` messages.

- [ ] **Step 3: Commit the module and test**

```bash
git add lua/core/messages.lua tests/messages_spec.lua tests/test_messages.sh
git commit -m "feat: add Neovim message buffer"
```

### Task 3: Load the recorder before plugins and verify configuration startup

**Files:**
- Modify: `init.lua:1-2`
- Test: `tests/test_messages.sh`

- [ ] **Step 1: Extend the test with an idempotency assertion**

Append this before the first `vim.notify` call in `tests/messages_spec.lua`:

```lua
messages.setup()
assert(messages.buffer() == buffer, "setup must reuse its message buffer")
```

- [ ] **Step 2: Run the test to verify the assertion fails before the integration change if setup is not idempotent**

Run: `bash tests/test_messages.sh`

Expected: PASS once Task 2 has made setup idempotent; this documents the
integration precondition rather than adding a second recorder.

- [ ] **Step 3: Load the module at startup**

Insert after `vim.loader.enable()` in `init.lua`:

```lua
require("core.messages").setup()
```

- [ ] **Step 4: Verify focused test and configuration parsing**

Run: `bash tests/test_messages.sh`

Expected: exit code 0.

Run: `nvim --headless -u init.lua '+qa'`

Expected: no Lua syntax error from `core.messages`; environment-specific plugin
errors may still occur and must be reported separately.

- [ ] **Step 5: Commit the integration**

```bash
git add init.lua tests/messages_spec.lua
git commit -m "feat: initialize message recorder early"
```
