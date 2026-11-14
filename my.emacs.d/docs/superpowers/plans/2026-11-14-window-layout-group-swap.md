# Window Layout Group Swap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add directional commands that exchange complete sibling window-layout groups and expose them through the existing `C-w` Hydra and window keymap.

**Architecture:** Represent the selected layout group and directional targets as paths through `window-tree`.  Convert those paths to corresponding nodes in the full `window-state-get` value, exchange the state nodes, restore the state with `window-state-put`, and select the leaf carrying the originally selected buffer content.  When more than one directional group can be chosen, Ace Window chooses any leaf in the desired group.

**Tech Stack:** Emacs Lisp, built-in `window-tree` / `window-state-get` / `window-state-put`, ERT, Ace Window, Hydra.

---

### Task 1: Add failing layout-state tests

**Files:**
- Modify: `user-lisp/init-window-tests.el`
- Modify: `user-lisp/init-window.el:81-141`

- [ ] **Step 1: Write failing tests for horizontal and vertical group swaps**

Add helpers that create named buffers and return a snapshot of the window tree's leaf-buffer names.  Add these tests before defining the implementation functions:

```elisp
(ert-deftest my/window-swap-group-right-moves-a-two-window-group-past-a-leaf ()
  (my/window-test-with-layout
      '((vertical "A" "B") "C")
    (select-window (get-buffer-window " *window-test-A*"))
    (my/window-swap-group-right)
    (should (equal (my/window-test-layout-names)
                   '(" *window-test-C*" (" *window-test-A*" " *window-test-B*"))))))

(ert-deftest my/window-swap-group-down-exchanges-horizontal-subtrees ()
  (my/window-test-with-layout
      '((horizontal "A" "B") (horizontal "C" "D"))
    (select-window (get-buffer-window " *window-test-A*"))
    (my/window-swap-group-down)
    (should (equal (my/window-test-layout-names)
                   '((" *window-test-C*" " *window-test-D*")
                     (" *window-test-A*" " *window-test-B*"))))))
```

- [ ] **Step 2: Run the focused test file and verify red**

Run:

```bash
emacs --batch -Q -l user-lisp/init-window-tests.el -f ert-run-tests-batch-and-exit
```

Expected: FAIL because `my/window-swap-group-right` and `my/window-swap-group-down` are not defined.

- [ ] **Step 3: Commit the red tests**

```bash
git add my.emacs.d/user-lisp/init-window-tests.el
git commit -m "test: define window layout group swap behavior"
```

### Task 2: Implement subtree discovery and state exchange

**Files:**
- Modify: `user-lisp/init-window.el:81-141`
- Test: `user-lisp/init-window-tests.el`

- [ ] **Step 1: Add pure tree helpers**

Add `my/window--tree-contains-p`, which recursively compares leaf windows and descends through `(cddr tree)` for a split node.  Add `my/window--group-path`, which recursively accumulates zero-based child indexes from the `window-tree` root, chooses the nearest ancestor whose direction is `nil` for `left`/`right` or `t` for `up`/`down`, and returns `(SOURCE-PATH TARGET-PATH)`.  Add `my/window--swap-state-children`, which follows the two paths in the `window-state-get` value, replaces each state node with the other node using `setcar`, and returns the mutated root state.  Add `my/window--leaf-with-buffer`, which scans `(window-list nil 'nomini)` and returns the leaf displaying the saved selected buffer and point marker.

`my/window--group-path` returns `nil` when no eligible sibling exists.  Its path indexes use the child portion of a `window-tree` node, so index zero corresponds to the first child after the node's direction and edges fields.

- [ ] **Step 2: Add the minimal interactive swapping commands**

```elisp
(defun my/window-swap-group (direction)
  "Exchange the selected window's layout group with its DIRECTION sibling."
  (interactive)
  (let ((selected-buffer (window-buffer))
        (selected-point (window-point)))
    (when-let ((paths (my/window--group-path (car (window-tree))
                                              (selected-window) direction)))
      (let ((state (window-state-get nil)))
        (my/window--swap-state-children state (car paths) (cadr paths))
        (window-state-put state (frame-root-window))
        (select-window (my/window--leaf-with-buffer selected-buffer selected-point))))))

(defun my/window-swap-group-left ()  (interactive) (my/window-swap-group 'left))
(defun my/window-swap-group-down ()  (interactive) (my/window-swap-group 'down))
(defun my/window-swap-group-up ()    (interactive) (my/window-swap-group 'up))
(defun my/window-swap-group-right () (interactive) (my/window-swap-group 'right))
```

The command must leave the layout unchanged and issue a `message` when no target exists.  It must exclude side and minibuffer windows.

- [ ] **Step 3: Run the focused tests and verify green**

Run:

```bash
emacs --batch -Q -l user-lisp/init-window-tests.el -f ert-run-tests-batch-and-exit
```

Expected: all existing navigation tests and the two new layout-swap tests pass.

- [ ] **Step 4: Commit the implementation**

```bash
git add my.emacs.d/user-lisp/init-window.el my.emacs.d/user-lisp/init-window-tests.el
git commit -m "feat: swap directional window layout groups"
```

### Task 3: Add Ace Window fallback and menu discoverability

**Files:**
- Modify: `user-lisp/init-window.el:20-56`
- Modify: `user-lisp/init-window.el:207-287`
- Modify: `user-lisp/init-window-tests.el`

- [ ] **Step 1: Write failing tests for key bindings and ambiguous targets**

Add tests verifying that `hydra-window-menu`'s hint contains `交换左侧布局组`, that its `H` head is `my/window-swap-group-left`, and that the `my-window-def` mapping contains the same command.  Add a test stub that binds an Ace selection function to return a leaf from a second eligible target group, then asserts that its group is the group swapped.

- [ ] **Step 2: Run the focused test file and verify red**

Run:

```bash
emacs --batch -Q -l user-lisp/init-window-tests.el -f ert-run-tests-batch-and-exit
```

Expected: FAIL because uppercase group-swap menu heads and Ace fallback do not exist.

- [ ] **Step 3: Add candidate selection and bindings**

Add `my/window--select-group-target` that returns the sole directional target directly, or invokes `ace-window` with only the eligible target groups' leaf windows and maps the selected leaf to its owning group.  Extend the Hydra with these heads:

```elisp
("H" my/window-swap-group-left  :exit nil)
("J" my/window-swap-group-down  :exit nil)
("K" my/window-swap-group-up    :exit nil)
("L" my/window-swap-group-right :exit nil)
```

Add matching `my-window-def` entries with the labels `交换左侧布局组`, `交换下方布局组`, `交换上方布局组`, and `交换右侧布局组`.  Update the Hydra hint so these commands appear under a dedicated “布局组交换” heading.

- [ ] **Step 4: Run the focused test file and verify green**

Run:

```bash
emacs --batch -Q -l user-lisp/init-window-tests.el -f ert-run-tests-batch-and-exit
```

Expected: all tests pass, including the Ace fallback and menu assertions.

- [ ] **Step 5: Commit the bindings and tests**

```bash
git add my.emacs.d/user-lisp/init-window.el my.emacs.d/user-lisp/init-window-tests.el
git commit -m "feat: expose layout group swapping in window menu"
```

### Task 4: Full verification

**Files:**
- Verify: `user-lisp/init-window.el`
- Verify: `user-lisp/init-window-tests.el`

- [ ] **Step 1: Byte-load the configuration without third-party package startup**

Run:

```bash
emacs --batch -Q -l user-lisp/init-window-tests.el -f ert-run-tests-batch-and-exit
```

Expected: exit code 0 and all ERT tests pass.

- [ ] **Step 2: Check the working tree and patch formatting**

Run:

```bash
git diff --check
git status --short
```

Expected: no whitespace errors; only the intended implementation and test files are modified or committed.
