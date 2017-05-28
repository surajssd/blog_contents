+++
linktitle = ""
description = "Shortcuts of intellij and also some short notes"
date = "2017-03-17T14:41:51+05:30"
title = "Intellij Shortcuts"
featuredalt = ""
featured = ""
categories = ["ide", "notes"]
author = "Suraj Deshmukh"
featuredpath = ""
tags = ["intellij", "ide", "programming", "productivity", "notes"]

+++



**Note**: This is a living document and will be updated as I discover new things.

## Shortcuts

- `Ctrl + Shift + A`

Find any action in IDE

- `Ctrl + Shift + F`

Find in Path

- `Alt + 1`

Open project navigator.
You can search here, just start typing here, after the project navigator window is opened.

- `Shift + Insert` in Project window

Here you can add new file to the project. The filename could be the entire path, so the intermediate directories will be created for you.

- `Ctrl + N`

Find a struct or class definition by name.

- `Ctrl + Shift + N`

Find a file by name.
If you type file name and number seprated by number it will take you to the line in that file. e.g. `main.go:6` This will take you to line 6 in `main.go`.

- `Ctrl + Shift + Alt + N`

Find any symbol in the project. Here symbol means mainly type.

- `Shift + Shift`

Search anything anywhere.

- `Ctrl + F4`

Close section that is active.

- `Ctrl + Tab`

Switcher to switch between open items

- `Ctrl + Shift + B`

Jump to definition.

- `Ctrl + B`

Find usage of that element in project. Or find declaration of a variable.

- `Ctrl + Shift + P`

Find type of a variable.

- `Ctrl + cursor up/down`

Navigate the code window up and down

- `Ctrl + D`

Duplicate a line or selection.

- `Ctrl + Y`

Delete a line or selection.

- `Ctrl + /`

Comment/Uncomment out with line comment, a line or selected block.

- `Ctrl + Shift + /`

Comment/Uncomment out with block comment, a line or selected block.

- `Alt + Shift + cursor up/down`

Move line or selection up/down.

- `Alt + ->` or `Alt + <-`

Switch tabs of open files.

- `Ctrl + E`

Show recently openend files.

- `Ctrl + Shift + A` 'Scratch files'

If you need files that are not part of project but need to test something.

- `Ctrl + Shift + F12`

Hide all the windows and make editor full screen and press again to go back to having all the windows.

- `View + Enter Distraction Free mode`

This will only keep editor rest everything goes away.

- `Ctrl + Shift + <-` or `Ctrl + Shift + ->`

When in the project navigation window you can resize it.

- `Ctrl + W`

Select a word, press again and select a line, then select entire line then entire block, then entire outcasting block and so on.

- `Shift + Alt + up/down cursor`

When a line or block of code is selected and wanna move up and down.

- `Ctrl + Shift + V`

To see your clipboard history

- `Alt + mouse click in location`

To have multiple cursors. To get out of this mode just press `escape` key.

- `Alt + J`

When pressed on a word, it finds the next occurrence of the word and puts a cursor there. So I can edit mutiple occurrences of same word simultaneously.

- `Ctrl + Alt + I`

Select a block of code and get indentation right.

- `Ctrl + Alt + L`

Reformat the code.

- `Alt + Enter`

Goto a string and press this key and then you can do language injection. So you can tell intellij to interpret that string as `json` or something like that.
So this helps in adding markup languages as string as a part of code. Also you can inject `regular expression` and then check if the string is validated
against the regular expressions you put in.

- `Alt + /`

So when a recommendation is opened up and if you press above key combination, the word is completed but if you keep pressing those keys the recommendation
rotates through all the recommendation.

- `Ctrl + J`

Recommend templates, if there are any pre-defined.

- `Ctrl + Shift + Enter`

Auto complete the current statement.

- `Ctrl + F12`

Navigate file structure, you can start typing and search for things. And then by pressing the enter key you can jump to the definition.

- `Alt + 7`

Similar functionality as above only difference is that it opens in a side bar.

- `Ctrl + Shift + A` 'annotate'

Start annotation to see who made changes on each line. From here you can copy the revision number and then search it in the 'version control' window.

- `Alt + F12`

Terminal in IDE

- `Alt + 9`

Version Control window


## Notes and Tips

- In code you can write TODOs and FIXME and then IDE can identify them and you can write code later on in there.
- There is a plugin called as 'Presentation Assistant' which shows what keys did you type
- In the project window(side bar), select *Auto Scroll from Source* so when you are moving from one file to another it shows in the project side bar where that file is right now.
- When navigating in the project side bar, to start editing certain file press function key `F4`. Press `Enter` to just view it.


## Other receipes

#### Compare branches

- Press `Ctrl + Shift + A` to open the action window, search for `branches`, open branches window. Also can be done [as](https://www.jetbrains.com/help/pycharm/2016.1/accessing-git-branches-popup-menu.html).
- Once branch pop-window is open, select with what branch you wanna compare current checked out branch and select `compare`.
- It will open up a window with all changes, in top tabs select `diff`, then select a file you wanna compare.
- Above steps are also given [here](https://www.jetbrains.com/help/pycharm/2016.1/merging-deleting-and-comparing-branches.html).


## Ref:

- [IntelliJ IDEA Tutorial - Shortcuts to Ditch Your Mouse Today](https://www.youtube.com/watch?v=vsyT-7n5-1I)
- [42 IntelliJ IDEA Tips and Tricks](https://youtu.be/eq3KiAH4IBI)
