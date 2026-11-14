# Window Layout Group Swap Design

## Goal

Add directional commands that swap whole window-layout groups, rather than moving point or swapping individual adjacent windows.  A group is a subtree of the selected window's nearest horizontal or vertical split.  The commands preserve the full internal structure of each group.

## Interaction

- Keep lowercase `h`, `j`, `k`, and `l` as the existing directional point-navigation commands.
- Add uppercase `H`, `J`, `K`, and `L` for group swapping: left, down, up, and right respectively.
- Given `AB | CD`, running `L` from a window in `AB` produces `CD | AB`.
- Groups may have different shapes and numbers of leaf windows: `AB | C` becomes `C | AB`.
- The same rule applies to vertical layouts.  For example, an upper `AB` group and a lower `CD` group exchange places while retaining their internal layouts.

## Group Discovery and Selection

1. Start from the selected live, non-minibuffer window.
2. Locate the relevant nearest ancestor split for the requested axis: horizontal for `H`/`L`, vertical for `J`/`K`.
3. Treat the selected ancestor child as the source subtree.  Find sibling subtrees located in the requested direction.
4. If exactly one directional sibling is eligible, use it as the target.
5. If multiple sibling groups are eligible, invoke Ace Window over their leaf windows.  Selecting any leaf identifies its owning sibling subtree; that full subtree becomes the target.
6. Side windows, including Treemacs, and minibuffer windows are excluded from both source and target candidates.

## Swap Semantics

- Capture each selected subtree's complete window state, including its layout, buffers, window points, and scroll positions.
- Rebuild the two states in the opposite sibling positions while preserving the parent split and its proportions as far as Emacs permits.
- Keep the selected window logically associated with its original content after the swap by selecting the corresponding window in the destination subtree.
- If there is no sibling in the requested direction, leave the layout unchanged and show a concise message.
- If Ace selection is cancelled, leave the layout unchanged.

## Integration

- Implement the helpers and commands in `user-lisp/init-window.el` alongside the existing directional navigation helpers.
- Register the uppercase commands in both `hydra-window-menu` and `my-window-def`, with descriptions that distinguish them from point navigation.
- Retain existing lower-case movement, Ace Window dispatch, normal window splitting, and Treemacs handling unchanged.

## Verification

- Automated ERT coverage constructs representative layouts and verifies: `AB | CD` becomes `CD | AB`; `AB | C` becomes `C | AB`; and vertically stacked groups exchange analogously.
- Tests verify that each group's internal arrangement and buffer assignment are preserved, source content remains selected after the swap, and a missing/cancelled target makes no change.
- Run the focused ERT tests, load the edited Emacs Lisp file in batch mode, and run `git diff --check`.
