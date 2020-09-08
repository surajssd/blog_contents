+++
author = "Suraj Deshmukh"
date = "2019-06-23T11:57:07+05:30"
title = "Project specific scripts"
description = "Instead of polluting your PATH the easier way to put project specific scripts"
categories = ["host", "linux", "desktop"]
tags = ["host", "linux", "desktop"]
+++

There are always scripts that you write to automate some mundane tasks. And then you put that script in a directory that is in your `PATH`. But what this does is that it pollutes your system global `PATH` and shows up in places you wouldn't want it to be in.

I was struggling with this issue for a while and struggling to get a proper solution. But there is a very simple and clever trick to solve this problem. You extend your `PATH` to have a relative path `.scripts` in it. Like following (this is a snippet from my `.bashrc`).

```bash
export PATH=$PATH:.scripts
```

And also add this directory to your global gitignore file. This should be done so that when you put this `.scripts` directory in your project the git should ignore it and not look at it as the change you would want to push to the git repository. Here is a snippet from my `gitignore` file.

```bash
$ grep scripts ~/.gitignore
17:# ignore the local scripts directory
18:.scripts
```

Now on what you can do is put the scripts you want to be available in a particular project into a directory called `.scripts`. Like for example:

```bash
$ ll -a
drwxrwxr-x@    - surajd 17 Jun 14:38 .scripts/
drwxrwxr-x@    - surajd  4 Jun 15:51 .terraform/
.rw-rw-r--@  162 surajd 11 Jun 14:03 locals.tf

$ ll .scripts/
.rwxrwxr-x@ 141 surajd 14 Jun 12:00 redeploy.sh*
```

Now you can see that whenever I am in this directory `redeploy.sh` is available for me to run. When I press tab key the autocomplete shows up the results.

```bash
$ red<tab>
red          redeploy.sh
```

Now I just create those scripts directories and my global `PATH` is not polluted and it makes me happy.

I have penned down the other aspects of scripts management in my post called: [Framework for managing random scripts and binaries](https://suraj.io/post/framework-for-scripts-and-binaries/).
