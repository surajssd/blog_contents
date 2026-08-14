---
author: "Suraj Deshmukh"
date: "2026-08-14T10:05:25-07:00"
title: "Ghostty as a Shell for Herdr"
description: "Strip Ghostty down to a dumb container and send every iTerm2-style shortcut straight to Herdr, no prefix key required."
draft: false
categories: ["tools", "terminal"]
tags: ["ghostty", "herdr", "terminal", "macos", "productivity"]
cover:
  image: "/post/2026/images/ghostty-herdr/ghostty-herdr.png"
  alt: "The Herdr ram logo glowing inside the Ghostty terminal icon"
---

## One terminal inside another

I use [Herdr](https://herdr.dev) every day to run AI coding agents. It is a terminal workspace manager: think tmux, but mouse-first and agent-aware, with a sidebar that shows what every agent is doing across all my projects. Once Herdr owns the workspaces, tabs, and panes, the terminal emulator around it only needs to draw text fast and stay out of the way.

For me, that outer terminal is [Ghostty](https://ghostty.org/docs). Out of the box, though, the two fight over the keyboard. Ghostty ships with its own macOS-native defaults: `Cmd+T` opens a Ghostty tab, `Cmd+1..9` switches Ghostty tabs, and `Cmd+D` splits a Ghostty pane. Herdr wants those same chords for its tabs, workspaces, and splits. A keystroke has to survive three layers before Herdr sees it: the OS, the outer terminal, and whatever is running inside the pane. Ghostty was eating mine at layer two.

I could use Herdr's tmux-style prefix (`ctrl+b`, then a key) and stop there. But I came from iTerm2, and `Cmd+T` for a new tab is muscle memory. `prefix+c` never will be.

## The detour through cmux

Before settling on Herdr, I tried [cmux](https://cmux.com/docs/getting-started), a native macOS terminal that uses libghostty for rendering and is built for managing multiple AI coding agents. It had the pieces I wanted in one app: workspaces, vertical tabs, agent notifications, and familiar shortcuts already assigned.

On my machine, cmux was heavy enough to bring my M5 Pro with 48 GB of memory to its knees. I also ran into two basic interaction problems: I could not click the tabs, and the keyboard shortcuts did not switch between them. Those problems made a tab-centric agent manager hard to use.

Herdr fit me better because its model resembles tmux. A background server owns the session, and a terminal client connects to it. I can run it inside Ghostty on my laptop or on a remote machine over SSH. The panes and agents live in Herdr, not in the terminal window. I just have to wire up the shortcuts myself. That brings us back to Ghostty.

## Ghostty is a config file, not a preferences pane

Ghostty makes this possible without a settings UI. Everything lives in one config file, and I can remove its bindings one at a time:

```ini
keybind = cmd+t=unbind
```

After that, Ghostty no longer claims `Cmd+T`. The chord falls through to the program inside the terminal. The first part of my config strips out everything Herdr wants:

```ini
# Let Herdr receive these instead of Ghostty.
keybind = cmd+t=unbind
keybind = cmd+w=unbind
keybind = cmd+n=unbind
keybind = cmd+shift+w=unbind

keybind = cmd+d=unbind
keybind = cmd+shift+d=unbind
keybind = cmd+shift+enter=unbind

keybind = cmd+alt+left=unbind
keybind = cmd+alt+down=unbind
keybind = cmd+alt+up=unbind
keybind = cmd+alt+right=unbind

# Navigate Herdr's vertical workspace list.
keybind = cmd+shift+up=unbind
keybind = cmd+shift+down=unbind

# Navigate detected agents in Herdr's Agents sidebar.
keybind = cmd+ctrl+up=unbind
keybind = cmd+ctrl+down=unbind
```

Herdr opts into the [Kitty keyboard protocol](https://sw.kovidgoyal.net/kitty/keyboard-protocol/), which Ghostty knows how to encode. While Herdr is running, Ghostty can report modifiers that classic terminal encodings cannot express, including macOS's `Cmd` key. Once a Ghostty binding is out of the way, Herdr can match the chord directly.

## Forcing the exact key event

Most chords only need `unbind`. I handle numbered tabs and the shifted bracket shortcuts differently: Ghostty's `text:` action writes the exact Kitty sequence Herdr expects. Number keys are awkward because Ghostty registers both a character trigger (`1`) and a physical-key trigger (`Digit1`) for its native tab shortcuts, so my config overrides both forms.

```ini
# Forward exact Kitty keyboard events to preserve the bracket key, Shift,
# and Command modifiers for Herdr tab navigation.
keybind = cmd+shift+left_bracket=text:\x1b[91:123;10u
keybind = cmd+shift+right_bracket=text:\x1b[93:125;10u

# Forward Cmd+1..9 as exact Kitty keyboard events so Herdr selects its tabs
# instead of Ghostty selecting native tabs.
keybind = cmd+1=text:\x1b[49;9u
keybind = cmd+Digit1=text:\x1b[49;9u
keybind = cmd+2=text:\x1b[50;9u
keybind = cmd+Digit2=text:\x1b[50;9u
# ... repeat both forms through 9

# Use Cmd+Control+1..9 for numbered Herdr workspaces, leaving macOS's
# Cmd+Shift+number shortcuts untouched.
keybind = cmd+ctrl+1=text:\x1b[49;13u
keybind = cmd+ctrl+Digit1=text:\x1b[49;13u
# ... repeat both forms through 9

# Jump directly to an agent by its visible 1..9 index.
keybind = cmd+ctrl+alt+1=text:\x1b[49;15u
keybind = cmd+ctrl+alt+Digit1=text:\x1b[49;15u
# ... repeat both forms through 9
```

The escape sequences look like line noise, but the Kitty format is simple: `ESC [ codepoint ; modifiers u`. The codepoint is the Unicode value of the key (`49` is the digit `1`, `91` is `[`), and the modifier field is `1` plus the sum of the held modifiers. Shift is 1, Alt is 2, Ctrl is 4, and Super (the Command key) is 8. That gives:

- `\x1b[49;9u` is `Cmd+1` (1 + 8 = 9)
- `\x1b[49;13u` is `Cmd+Ctrl+1` (1 + 4 + 8 = 13)
- `\x1b[49;15u` is `Cmd+Ctrl+Alt+1` (1 + 2 + 4 + 8 = 15)
- `\x1b[91:123;10u` is `Cmd+Shift+[`, where the `91:123` part carries both the base key `[` and its shifted form `{`, with modifiers 1 + 1 + 8 = 10

Herdr parses these handcrafted sequences as ordinary key events. At this point Ghostty only has to render and scroll. Herdr's shortcuts either pass through or get encoded explicitly.

## The Herdr side

Herdr's action bindings accept either a string or a list. That lets me keep the prefix bindings as a fallback and add the direct chords next to them:

```toml
[keys]
new_tab   = ["prefix+c", "cmd+t"]
close_tab = ["prefix+shift+x", "cmd+w"]

new_workspace   = ["prefix+shift+n", "cmd+n"]
close_workspace = ["prefix+shift+d", "cmd+shift+w"]
previous_workspace = "cmd+shift+up"
next_workspace     = "cmd+shift+down"
switch_workspace  = "cmd+ctrl+1..9"
previous_agent     = "cmd+ctrl+up"
next_agent         = "cmd+ctrl+down"
focus_agent        = "cmd+ctrl+alt+1..9"

split_vertical   = ["prefix+v", "cmd+d"]
split_horizontal = ["prefix+minus", "cmd+shift+d"]

previous_tab = ["prefix+p", "cmd+shift+["]
next_tab     = ["prefix+n", "cmd+shift+]"]
switch_tab  = ["prefix+1..9", "cmd+1..9"]

focus_pane_left  = ["prefix+h", "cmd+alt+left"]
focus_pane_down  = ["prefix+j", "cmd+alt+down"]
focus_pane_up    = ["prefix+k", "cmd+alt+up"]
focus_pane_right = ["prefix+l", "cmd+alt+right"]
zoom             = ["prefix+z", "cmd+shift+enter"]
```

My fingers do not have to learn a new scheme. `Cmd+T` opens a tab, `Cmd+N` opens a workspace, and `Cmd+D` splits the pane, just as they did in iTerm2. The difference is that the tabs and splits belong to Herdr. They persist when I close the window, and the agents inside them keep working.

Ghostty's config-only design works in my favor here. `unbind` gets Ghostty out of the way, while `text:` lets me encode a chord when I want exact bytes. The Kitty encoding is small enough to work out on a napkin: `ESC [ codepoint ; 1+modifiers u`.

I still keep the prefix bindings for SSH sessions from terminals I have not customized.

The full configs live in my dotfiles: [`config.ghostty`](https://github.com/surajssd/dotfiles/blob/master/configs/ghostty/config.ghostty) and [`config.toml`](https://github.com/surajssd/dotfiles/blob/master/configs/herdr/config.toml).
