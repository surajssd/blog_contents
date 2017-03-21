+++
author = "Suraj Deshmukh"
date = "2017-03-21T22:03:48+05:30"
title = "Git Notes"
description = "Contains notes about using git"
categories = ["git"]
tags = ["git", "notes"]

+++

Notes about using `git`.

## Tips and tricks

---

### Switch branches

  ```bash
  $ git checkout <branch>
  ```
---

### show

  ```bash
  $ git show
  ```

  Shows log message and diff about the commit you are on.

---

### blame

  To see who wrote the code? For each line of the file what commit edited that line of code will be shown. So now you can use that git commit and pass it to `git show <commit>` to see all the changes.

  ```bash
  $ git blame path/to/file
  ```
---

### cherry-pick

  To move a commit from one branch to another branch. Situation where: *I committed to master when I meant to commit to my feature branch. I need to move my commit!*

  Get the commit hash
  ```bash
  $ git show
  ```

  Change to the branch you wanted to add that commit
  ```bash
  $ git checkout <feature-branch>
  ```

  Add it to the branch you are on
  ```bash
  $ git cherry-pick <commit hash>
  ```

  `cherry-pick` creates an entirely new commit based off the original, and it does not delete the original commit. So you will have to delete it manually. See below how to do it.

  You can also get conflict during `cherry-pick`

  ```bash
  $ git cherry-pick 435bedfa
  ```

  Resolve the conflict and then
  ```bash
  $ git cherry-pick --continue
  ```
---

### reset

  Remove the last commit.

  ```bash
  $ git reset --hard HEAD^
  ```

  `HEAD`  : *the commit I'm currently sitting on*
  
  `HEAD^` : *this commit's parent*
  
  `HEAD^^`: *this commit's grandparent* and so on

---

### rebase

  - `rebase` is a command for changing history.
  - Never change history when other people might be using your branch, unless they know you're doing so.
  - Never change history on `master`.
  - Best practice: only change history for commits that have not yet been pushed.

  ```bash
  $ git checkout master
  $ git pull --ff upstream master
  $ git checkout <feature-branch>
  $ git rebase master -i
  ```

  While pushing need to do force push because there is change of history. Local branch and remote branch have diverged.
  ```bash
  $ git push origin <feature-branch> -f
  ```

  In case of conflicts, find the conflicting file.
  ```bash
  $ git status
  ```

  reolve those conflicts and then continue the rebase
  ```bash
  $ git status
  $ git rebase --continue
  ```
---
  
### Squashing commits

  - Amending the commit

  ```bash
  $ git add missing-file
  $ git commit --amend
  ```

  - Squashing

  Look at last 5 commits. Below command will open the text editor.

  ```bash
  $ git rebase --interactive HEAD~5
  ```

  Once in editor, you can select which ones to squash into previous one and ones to pick as it is. Now type new commit message to squashed commits.

---

### Splitting commits

  ```bash
  $ git rebase --i HEAD~3
  ```
  Now this will open the commit history in editor. The commit you want to split, change it from `pick` to `edit`. Save that file. Git will pause in the rebase process and give us time to create new commits.
  The too-big commit is already present, so let's pop it off, but keep the changes:

  ```bash
  $ git reset HEAD^
  ```
  Not using `--hard` because we want to have the changes we wanted. Make changes as needed. Now add individual file and commit. And continue rebase.

  ```bash
  $ git rebase --continue
  ```
---

### bisect

  *The feature's broken? But it was working fine 2 months ago... what changes?* Bisect will help you find the commit that introduced the problem.

  - Need commit where it was working, commit where it's broken and a test to verify that.

  ```bash
  $ git bisect start
  $ git checkout broken-commit
  $ git bisect bad
  $ git checkout working-commit
  $ git bisect good
  ```
---

### Git merge from someone else's fork

  Add their github fork repo as a remote to a clone of your own repo:

  ```bash
  $ git remote add other-guys-repo <url to other guys repo>
  ```
  Get their changes:

  ```bash
  $ git fetch other-guys-repo
  ```

  Checkout the branch where you want to merge:

  ```bash
  $ git checkout my_new_branch
  ```

  Merge their changes in (assuming they did their work on the master branch):

  ```bash
  $ git merge other-guys-repo/master
  ```

  Resolve conflicts, commit the resolutions and voila.
  Quick Ref: [http://stackoverflow.com/a/5606062](http://stackoverflow.com/a/5606062)

---

### How to pull remote branch from somebody else's repo

  ```bash
  $ git remote add coworker git://path/to/coworkers/repo.git
  $ git fetch coworker
  $ git checkout --track coworker/foo
  ```

  This will setup a local branch foo, tracking the remote branch coworker/foo. So when your coworker has made some changes, you can easily pull them:

  ```bash
  $ git checkout foo
  $ git pull
  ```

  Quick Ref: [http://stackoverflow.com/a/5884825](http://stackoverflow.com/a/5884825)

---

## Ref:

  - [Don't be afraid to commit](https://dont-be-afraid-to-commit.readthedocs.io/en/latest/)
  - Advanced Git - David Baumgold - [video](https://www.youtube.com/watch?v=4EOZvow1mk4), [slides](https://speakerdeck.com/singingwolfboy/advanced-git)
