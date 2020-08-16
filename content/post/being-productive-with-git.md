+++
author = "Suraj Deshmukh"
title = "Being Productive with Git"
description = "Tips and tricks to make your day to day usage easier."
date = "2020-08-16T22:00:51+05:30"
categories = ["git", "productivity", "bash", "notes"]
tags = ["git", "productivity", "notes"]
+++

## Contents

- [Introduction](#introduction)
- [Bash Aliases](#bash-aliases)
  - [Configuration](#configuration)
  - [Installation](#installation)
- [Global Git Configuration](#global-git-configuration)
  - [Configuration](#configuration-1)
  - [Installation](#installation-1)
- [Repository Specific Git Settings](#repository-specific-git-settings)
  - [Configuration](#configuration-2)
  - [Installation](#installation-2)
- [Bash Git Prompt](#bash-git-prompt)
  - [Configuration](#configuration-3)
  - [Installation](#installation-3)
- [Git Push](#git-push)
- [PR Reviews](#pr-reviews)
  - [Configuration](#configuration-4)
  - [Installation](#installation-4)
- [Demo](#demo)
- [Conclusion](#conclusion)


## Introduction

Git is a day to day tool for version control. It has become a de facto method of source code versioning, it has become ubiquitous with development and its an essential skill for a programmer. I use it all the time.

Because of its usage frequency, I wanted to optimise the number of keystrokes I made to get things done with it. I have made some tweaks and personalisation to my git workflow. Obviously, it involves aliases, scripts and other bash graphic tools.

## Bash Aliases

The most straightforward way to shorten any long Linux command is to use an alias. And I use quite a bunch of aliases for everyday git commands. I have aliases for things like checking out the `master` branch, pulling stuff from remotes commonly named `upstream` or `origin`, looking at git commits, rebasing and amending commits.

### Configuration

```bash
alias gpum="git pull --ff upstream master"
alias gpom="git pull --ff origin master"
alias gcm="git checkout master"
alias gs="git status"
alias gcmt="git commit -s"
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias grba="git rebase -i --autosquash "
alias gca="git commit --amend --no-edit"
```

### Installation

Above aliases you saw are placed in `~/.bashrc`. You can find mine [here](https://github.com/surajssd/dotfiles/blob/2c2d97642835d78b5ab62a25079d8c29d4f315a8/configs/bashrc#L27-L38).

## Global Git Configuration

### Configuration

The contents of gitconfig file look like this. I don't have a lot of customisation just basic stuff. In the following snippet `code` means [Visual Studio Code](https://code.visualstudio.com/). I use vscode as my primary editor so I prefer it to be my `difftool` as well. The entire [gitconfig](https://github.com/surajssd/dotfiles/blob/master/configs/gitconfig) is stored in my [dotfiles repository](https://github.com/surajssd/dotfiles/).

```
[user]
  name = Suraj Deshmukh
[color]
  diff = auto
  status = auto
  branch = auto
  interactive = auto
  ui = auto
  pager = true
[diff]
  tool = default-difftool
  noprefix = true
[difftool "default-difftool"]
  cmd = code --wait --diff $LOCAL $REMOTE
[core]
  excludesfile = ~/.gitignore
  editor = code --wait
```

### Installation

My global git configuration `~/.gitconfig` is not something I create manually. I have an unusual way of creating it. So if you look at the configuration, it is just a symlink to the actual file which resides in my dotfiles repository. I have a special way of creating these symlinks, which is explained in my previous blog [here](https://suraj.io/post/framework-for-scripts-and-binaries/).

```bash
$ ls -al ~/.gitconfig
lrwxrwxrwx@ 43 surajd 27 Jul  1:05 /home/surajd/.gitconfig -> /home/surajd/git/dotfiles/configs/gitconfig
```

## Repository Specific Git Settings

There are some settings I want only for that particular repository. For instance, for my work, I sign-off all my commits with my work email id. For those repository-specific settings, I have a script which does the job for me.

### Configuration

Right now this is all I do for work repository, so that's all I need.

```bash
git config user.email "me@work.com"
```

### Installation

You can copy above snippet in a file make it executable and place it in your `PATH`. I have this file in a dotfiles repository from where a script creates a symlink for this executable file and places in the `PATH`. All this script management framework is explained in my previous blog post [here](https://suraj.io/post/framework-for-scripts-and-binaries/). You can find the exact file [here](https://github.com/surajssd/dotfiles/blob/master/local-bin/set-git-config-kinvolk).

## Bash Git Prompt

Now when you are using plain old bash, it is not very helpful in terms of the context of the directory you are in. When you don't have a visual aid, it is easy to make mistakes like commit something on the wrong branch or other undesired things. So I use this helper utility called [bash-git-prompt](https://github.com/magicmonty/bash-git-prompt) which provides me with the git directory context. Like it tells me the path to the repository, the branch, the number of files changed, if the files are committed or untracked, exit code of the previous command, current time, etc. The bash prompt will change to look something like this when you are in a git repository:

```bash
✘-127 ~/git/blog_contents [foobar L|✚ 1…1]
23:01 $
```

### Configuration

You need to have these two settings in your `~/.bashrc`. So that the bash git prompt scripts are sourced every time the terminal starts.

```bash
# Bash Git Prompt
source ~/.bash-git-prompt/gitprompt.sh
GIT_PROMPT_ONLY_IN_REPO=1
```

### Installation

Again this is installed easily using this helper script I have [here](https://github.com/surajssd/dotfiles/blob/master/local-bin/update-git-prompt). So I just have to run the command `update-git-prompt`, and then the repository is installed to be consumed.

## Git Push

I have a script to push my changes to the PR I am working on. So every time I am done committing, I just need to do `gpo.sh`, and the changes are pushed to your `origin` remote. Behind the scene, there is a simple command which finds out what the current branch is and then push the current branch to `origin`.

```bash
git push origin $(git branch --show-current) "$@"
```

## PR Reviews

For PR reviews, it is tough to comprehend all the code just by looking on Github. So I like to pull those changes locally. There is a handy script for it that I use. All I run is something like `pr.sh 704 origin`, so this is pulling PR number 704 from the remote named `origin`. If you have to pull changes from `upstream` then specify such or whatever your remote name maybe.

### Configuration

```bash
random="${RANDOM}${RANDOM}"
git fetch "${remote}" "pull/${id}/head:pr_${id}_${remote}_${random}"
git checkout "pr_${id}_${remote}_${random}"
```

### Installation

I use my regular framework to install above `pr.sh`. You can find the entire file [here.](https://github.com/surajssd/dotfiles/blob/master/local-bin/pr.sh)

## Demo

- Step 1: Create branch:

```bash
git checkout foobar
```

- Step 2: Make changes as needed. Look at the changes:

```bash
gs
```

- Step 3: Add the changes:

```bash
git add .
```

- Step 4: Commit these changes:

```bash
gcmt
```

- Step 5: Push them:

```bash
gpo.sh
```

- Step 6: CI failed, and now you need to make changes. Make necessary fixes and follow step 2 to 3. Then to amend the last commit just run:

```bash
gca
```

- Step 7: Look at the git commits in the branch

```bash
gl
```

- Step 8: Force push changes now:

```bash
gpo.sh -f
```

## Conclusion

That was my tweaked Git workflow. Let me know your productivity hacks with git, in the comments or on twitter. Thanks for reading. Happy Hacking!
