# Introduction

"Emacs Pinky" is a condition where you feel pain in one or both of
your pinky fingers from using Emacs. This is because Emacs requires
you to hold `[Ctrl]` to do anything other than inserting text. On
most keyboards, `[Ctrl]` is pressed with the pinky, so this causes a
lot of stress.

What can you do about this though? Switch to Vim? You'll have to
learn a new set of key bindings and throw away all your
customizations! It will be awful!

pinky-mode to the rescue! pinky-mode is a minor mode which lets you
use most common navigation commands without touching `[Ctrl]`. It is
inspired by command mode in Vim. Once activated, use Vim-style motions
to navigate your buffer. For example, press `j` to move to the next
line and `w` to move to the next word.
See the full list of key bindings below. Press i to leave pinky-mode
and go back to inserting text.

When pinky-mode is active, the cursor color will change, and
"Pinky" will be shown in the mode line. You can customize the cursor
color with `M-x customize-group RET pinky RET`.

## Installation:

Once the pinky-mode package is installed, add this to your .emacs:

```elisp
(require 'pinky-mode)
```

You will need to bind pinky-mode-activate to something you can
press easily. I use the key-chord package to bind this to `jk`
(press `j` and `k` at the same time). This is entirely up to you
though.

```elisp
(require 'key-chord)
(key-chord-mode 1)
(key-chord-define-global "jk" 'pinky-mode-activate)
```

To force yourself to learn pinky-mode, consider disabling the
normal key bindings for navigation.

```elisp
(pinky-unbind-normal-keys)
```

## List of key bindings

### Basic motions

| Key | Motion |
| --- | --- |
| `h` / `j` / `k` / `l` | left / down / up / right |
| `w` / `b` / `e` | next word / previous word / word end |
| `W` / `B` / `E` | next WORD / previous WORD / WORD end |
| `0` / `^` / `$` | line start / first non-blank / line end |
| `.` | repeat the latest repeatable command |
| `i` | leave pinky-mode |

### Precise motions on the current line

| Key | Motion |
| --- | --- |
| `f{char}` / `F{char}` | find a character forward / backward |
| `t{char}` / `T{char}` | move until a character forward / backward |
| `;` / `,` | repeat / reverse the latest character find |

### Vertical and large-range motions

| Key | Motion |
| --- | --- |
| `gg` / `G` | beginning / end of buffer |
| `ge` / `gE` | previous word end / previous WORD end |
| `g_` | last non-blank character on the line |
| `(` / `)` | previous / next sentence |
| `{` / `}` | previous / next paragraph |
| `H` / `M` / `L` | top / middle / bottom visible line |

### Screen and viewport

| Key | Motion |
| --- | --- |
| `C-f` / `C-b` | page down / page up |
| `C-d` / `C-u` | half-page down / half-page up |
| `C-e` / `C-y` | scroll viewport down / up one line |
| `zz` / `zt` / `zb` | place current line at middle / top / bottom |
| `z.` / `z RET` / `z-` | Vim aliases for middle / top / bottom |

### Folding

| Key | Motion |
| --- | --- |
| `za` | toggle the fold at point |
| `zo` / `zc` | open / close the fold at point |
| `zR` / `zM` | open / close all folds |
| `zd` | delete or clear the fold at point |

### Editing

| Key | Action |
| --- | --- |
| `dd` / `cc` | delete / change the current line |
| `d{motion}` | delete using `w W b B e E 0 ^ $ gg G { }` |
| `c{motion}` | change using `w W b B e E 0 ^ $ gg G { }` |
| `diw` / `ciw` | delete / change the complete word at point |
| `daw` / `caw` | delete / change the word and adjacent whitespace |
| `diW` / `ciW` | delete / change the complete whitespace-delimited WORD |
| `daW` / `caW` | delete / change the WORD and adjacent whitespace |
| `D` / `C` | delete / change to the end of the line |
| `s` | substitute the character at point and return to insertion |
| `x` | delete the character at point |
| `r{char}` | replace the character at point |
| `R` | enter continuous replace mode; leave it with `ESC` or `C-g` |
| `u` / `C-r` | undo / redo |
| `.` | repeat the latest Pinky editing command |

Change commands such as `ciw`, `cw`, `cc`, and `s` temporarily suspend the
navigation keymap so normal text can be inserted, but they keep pinky-mode and
its passive Transient menu open.  Press `ESC` or `C-g` once to return to Pinky
navigation.  In navigation state, use the configured Pinky toggle (`i` or
`ESC`) to close the mode and menu explicitly.  `R` follows the same lifecycle
while using overwrite input.

### Search

| Key | Motion |
| --- | --- |
| `/` / `?` | search forward / backward |
| `n` / `N` | next / previous search result |

Number keys are not used for window selection, and pinky-mode has no
dependency on window-number.
