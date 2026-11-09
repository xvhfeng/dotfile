# C-w Window Hydra Design

## Goal

Replace the `C-w` window-operation Transient menu with one persistent Hydra
while preserving the existing commands, key bindings, and three-column help
layout.

## Interaction

`C-w` invokes `hydra-window-menu/body` directly.  The Hydra displays the
existing three groups: selection and navigation, splitting, and layout or
resizing.  Every existing command keeps its key and description.

Window commands keep the Hydra active so several operations can be issued in
one session.  `q`, `RET`, `ESC`, and `C-g` exit through Hydra's normal
mechanism.  `r` enters the existing resize Hydra; leaving it returns to normal
editing rather than reopening the parent menu.

## Scope

Remove the Transient dependency and the menu-specific lifecycle integration:
`(require 'transient)`, `(require 'init-transient-lifecycle)`,
`my/window-menu`, and `my/window-menu-open`.  Bind `C-w` directly to the new
Hydra body.

The `C-c w` General/Which-Key command map, individual window commands,
Treemacs navigation handling, and resize Hydra remain unchanged.

## Verification

Keep the Treemacs navigation ERT coverage.  Add coverage that `C-w` resolves
to the new Hydra and that the retired Transient menu symbols are absent.  Run
the focused ERT file and Emacs Lisp syntax checks after the change.
