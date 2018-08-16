+++
author = "Suraj Deshmukh"
description = "Shortcuts for vscode and some notes"
date = "2018-02-22T08:00:51+05:30"
title = "vscode Shortcuts"
categories = ["ide", "notes"]
tags = ["vscode", "editor", "programming", "productivity", "notes"]
+++

This post has shortcuts that are generic and golang specific as well. This post will edited from time to time.

## Shortcuts

- Toggle side bar

`Ctrl + B`

- Project explorer in side bar

`Ctrl + Shift + E`

- Project wide search in side bar

`Ctrl + Shift + F`

- Source control in side bar

`Ctrl + Shift + G`

- Copy entire line

`Ctrl + C` (without any selection)

- Delete entire line

`Ctrl + Shift + K`

- Toggle terminal

`Ctrl + ~ `

- Toggle problems/errors in current project

`Ctrl + Shift + M`

- Select entire line

`Ctrl + I` keep pressing `I` and then next line gets selected

- Move line or selected block up/down

`Alt + up` **OR** `Alt + down`

- Insert line below

`Ctrl + Enter`

- Insert line below

`Ctrl + Shift + Enter`

- Multiple cursors at random place

`Alt + Mouse click`

- Multiple line cursor

`Shift + Alt + up/down`

- Get cursor on multiple occurrences of string

`Ctrl + Shift + L`

- Comment line or selected block

`Ctrl + /`

- Reformat code

`Ctrl + Shift + I`

- Fold code block

`Ctrl + Shift + [`

- Unfold code block

`Ctrl + Shift + ]`

- Fold all sections

`Ctrl + K and Ctrl + 0`

- Unfold all sections

`Ctrl + K and Ctrl + J`

- Navigate through all errors in file

`F8`

- Open command pallette

`F1` **OR** `Ctrl + Shift + P`

- Fuzzy search & open a file

`Ctrl + P`

- Zen mode

`Ctrl + K and Z`

- Trigger Intellisense

`Ctrl + Space`

- Go back to last where you were in file

`Ctrl + Alt + -`

- Go forward

`Ctrl + Shift + -`

- Vertically split editor

`Ctrl + \`

- Vertically split editor 

From project bar just select file and press `Ctrl + Enter`

- Switch among splits

`Ctrl + 1` **OR** `Ctrl + 2`

- Navigate by symbols in a file

`Ctrl + Shift + O`

- Goto line number

`Ctrl + G` now enter line number

- Undo last cursor operation

`Ctrl + U`

## Tricks

- Use vscode as diff tool

```bash
code --diff <file1> <file2>
```

- Code Snippets

This is small code templates or snippets which can help getting started boiler plate code.

For e.g. in golang file just type `fmain` and `TAB` you should see recommendation for main
function. To see all snippets and what their short syntax is search for `insert snippet` in
command palette. You can also add custom snippets.

## Reference

- [Linux Shortcuts cheatsheet](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-linux.pdf)
- [VSCode: 10 Most Useful Tips And Tricks](https://www.youtube.com/watch?v=cVGMldhVRxU).
This video also shows how to configure task runner and then setup a custom key binding.
- [Best of Visual Studio Code - Tips and Tricks](https://youtu.be/GQ9nr3d5fUk)
