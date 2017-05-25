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

### status

  ```bash
  $ git status -sb
  ```

  Show status in short format and also give branch info

---

### show

  ```bash
  $ git show
  ```

  Shows log message and diff about the commit you are on.

---

### log

  ```bash
  $ git log -L 70,100:pkg/transformer/kubernetes/kubernetes.go
  ```
  Get logs on file between line numbers.

  ```bash
  $ git log --graph --abbrev-commit
  ```

  Show graph in logs.

---

### commit

  ```bash
  $ git add -p
  ```

  Commit only parts of file. Interactively choose chunks of patch.

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


  Remove the changes that were accidentally added and not comitted.

  ```bash
  $ git reset HEAD
  ```

  If you don't want to have the uncommitted changes.

  ```bash
  $ git reset --hard HEAD
  ```

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

### Use the same commit message

  Use the commit message that was generated automatically

  ```bash
  git merge --no-edit
  ```

  **OR**

  ```bash
  git commit --amend --no-edit
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

### Auto-correct mis-types in commands

  ```bash
  $ git config --global help.autocorrect 10
  ```
---

### Edit git output colors

  Set various colors to the git logs and all the git output

  ```bash
  $ git config --global color.ui auto
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

### How to pull remote branch from somebody else's PR

  ```bash
  $ git remote add coworker git://path/to/coworkers/repo.git
  $ git fetch coworker
  $ git checkout --track coworker/foo
  ```

  This will setup a local branch `foo`, tracking the remote branch `coworker/foo`. So when your coworker has made some changes, you can easily pull them:

  ```bash
  $ git checkout foo
  $ git pull
  ```

  Quick Ref: [http://stackoverflow.com/a/5884825](http://stackoverflow.com/a/5884825)

  **OR**

  Add following code snippet to `~/.bashrc`, this will way you have alias to pull any PR.

  ```bash
  function pr() {
      id=$1
      if [ -z $id ]; then
          echo "Need Pull request number as argument"
          return 1
      fi
      git fetch upstream pull/${id}/head:pr_${id}
      git checkout pr_${id}
  }
  ```

  Usage
  ```bash
  pr <pr_number>
  ```


---

### Tips on writing git commits

- [How to Write a Git Commit Message](https://chris.beams.io/posts/git-commit/)
- [Conventional Commits 1.0.0-beta.1](http://conventionalcommits.org/)

---

### Tools

- [Commitizen - Helps in writing commits](http://commitizen.github.io/cz-cli/)
- [Bash Git Prompt](https://github.com/magicmonty/bash-git-prompt)


  Install using following:
  ```bash
  cd && git clone https://github.com/magicmonty/bash-git-prompt.git .bash-git-prompt

  echo '
  #======================================
  # bash git prompt

  source ~/.bash-git-prompt/gitprompt.sh
  GIT_PROMPT_ONLY_IN_REPO=1
  #======================================
  ' | tee -a ~/.bashrc
  ```

---

## Github

These are tips about using github.com

- *allow edits from maintainers*

  This will help so that maintainers can push on your branch. On the PR at bottom right corner there is a check box to enable that.

- Patch from PR

  If you want a patch/diff of changes in a PR just goto PR and at the end of the url put `.patch` and you will see formatted patch. e.g. goto [PR](https://github.com/kubernetes-incubator/kompose/pull/454) and now the [patch](https://patch-diff.githubusercontent.com/raw/kubernetes-incubator/kompose/pull/454.patch)

- Compare ranges

  goto `https://github.com/<org>/<project>/compare/<old_version>...<new_version>`

  **OR**

  goto `https://github.com/kubernetes-incubator/kompose/compare/v0.3.0...v0.4.0`

  Compare things like branches, releases, etc.

- Compare, patch ranges

  goto `https://github.com/<org>/<project>/compare/<branch>...<branch>.patch`

  **OR**

  goto `https://github.com/kubernetes-incubator/kompose/compare/v0.3.0...v0.4.0.patch`

- Anchors on line numbers

  Click on the line number and shift click on another line later to select a block of code.

- References and closing issues/PRs

  Also you can add closes while merging the PR.

- Code search

  ```
  repo:kubernetes-incubator/kompose is:pr registry in:title
  ```

  *registry* is the string I am searching in the *kubernetes-incubator/kompose* repo, which has that string in PR in title.

  **OR**

  ```
  repo:openshift/origin is:issue ubuntu
  ```

  When doing things on github you will find queries like these automatically generated.

- Keyboard Shortcuts

  * `?` for all the shortcuts.
  * Use `t` to search for files, fuzzy search, you need only file name not the full file path.

  Others can be found using `?`.

- Gists as full repos

  gists can act as full repos

- Embedding the gist

  Add `.pibb` at the end of the gist link, you can use it on github pages and other places.

- Short link to your github profile pic

  `https://github.com/surajssd.png` **OR** `https://github.com/<github_username>.png`

- Short url with github

  Goto [git.io](https://git.io/) and shorten any github url.

- Blame

  On any file in github, you can click the blame button and see who made what changes. After clicking on some specific commit, you can see the complete change and from the commit message goto PR for seeing all the discussion.

- Global list of issues, PRs

  In the top bar there are buttons for global list of issues and PRs. This can be a good todo list. In issues you can see issues you have created or assigned or mentioned.

- Writing a very huge comment

  ```
  <details>
    write whatever here that needs to be hidden
  </details>
  ```

---

## Ref:

  - [Don't be afraid to commit](https://dont-be-afraid-to-commit.readthedocs.io/en/latest/)
  - Advanced Git - David Baumgold - [video](https://www.youtube.com/watch?v=4EOZvow1mk4), [slides](https://speakerdeck.com/singingwolfboy/advanced-git)
  - [Searching GitHub](https://help.github.com/articles/searching-github/)
  - Tips & Tricks: Gotta Git Them All - GitHub Universe 2016, [video](https://youtu.be/LsxDxL4PYik).
  - Everything I Wish I Knew When I Started Using GitHub - oscon Portland 2015, [video](https://youtu.be/KDUtjZHIx44).
  - [How to revert a “git rm -r .”?](http://stackoverflow.com/a/2125738/3848679)
  - [How to make “spoiler” text in github wiki pages?](http://stackoverflow.com/a/39920717/3848679)
  - [20 Tricks with Git and Shell, Spencer Krum - Git Merge 2016](https://youtu.be/d-T51nhmFhQ)

