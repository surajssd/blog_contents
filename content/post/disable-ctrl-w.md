+++
author = "Suraj Deshmukh"
title = "How to disable your Chrome Ctrl + W keybinding"
description = "Learn how to disable the shortcut Ctrl + W altogether on your GNOME"
date = "2018-10-16T22:00:51+05:30"
categories = ["fedora", "gnome"]
tags = ["fedora", "gnome", "desktop", "cka"]
+++

I am about to attempt the [CKA exam](https://www.cncf.io/certification/cka/) and it has a browser based terminal. And I am used to this terminal shortcut `Ctrl + W` which deletes a word. But the same shortcut in browser can close a tab. Since this exam is combination of both I am afraid I might close my exam tab while deleting a word in terminal. Now the only solution to this is disabling the shortcut in chrome. But turns out that the shortcut is [hard coded in chrome](https://productforums.google.com/forum/#!msg/chrome/ZXtMxfqpULs/9vWwfWUVAEIJ).

I use [Fedora Linux](https://getfedora.org/) with [GNOME](https://www.gnome.org/) as my desktop environment. So the alternative to this problem is you just add this keybinding as a no operation in GNOME. So I am going to add this as a no-op till the exam and remove this once I am done with the exam. So here are the steps to do it.

## Steps to disable "Ctrl + W"

Open `Keyboard` in your `Settings`, you can just type in the GNOME search.

![](/images/disable-ctrl-w/0.png "")

Once you open `Keyboard` you can see bunch of shortcuts listed there.

![](/images/disable-ctrl-w/1.png "")

Goto the bottom of it and click on the plus button.

![](/images/disable-ctrl-w/2.png "")

Now you can add a custom shortcut here, `Name` it something so that you remember that you want to remove it later and in `Command` put some no-op thing. After that click on `Set Shortcut` to provide key binding.

![](/images/disable-ctrl-w/3.png "")

Type key combination of `Ctrl + W` here

![](/images/disable-ctrl-w/4.png "")

Your custom shortcut should look like this, and click the `Add` button.

![](/images/disable-ctrl-w/5.png "")

That's how you will have your `Ctrl + W` disabled.
