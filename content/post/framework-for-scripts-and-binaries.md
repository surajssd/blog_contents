+++
author = "Suraj Deshmukh"
title = "Framework for managing random scripts and binaries"
description = "This is an explanation of the framework that I have created to manage scripts and binaries."
date = "2020-07-18T19:00:51+05:30"
categories = ["bash", "productivity", "packaging", "notes"]
tags = ["bash", "productivity", "notes"]
+++

I always had a conundrum about how to manage the scripts and binaries downloaded randomly from the internet. One way is to put them in the global `PATH` directory like `/usr/local/bin`, but I am sceptical about it.

There are a couple of things I wanted to solve. How do you update these scripts and binaries? How to do it consistently across all my machines? How to make it easier to have my setup available on any new Linux machine(or even container) I setup? How to do it without `sudo`?

## Managing random scripts

### Global scripts

I have a [Github repository](https://github.com/surajssd/dotfiles) where I have all my scripts and configurations. In the past, I use to copy these scripts into another directory which is in `PATH` viz. `~/.local/bin`. This directory is added to `PATH` in Fedora by default.

Now the problem with this copying approach was that if I had to make any corrections to the script because I found a bug. I had to make those changes in two places, one in the Github repository directory and other in the `~/.local/bin` directory. As a human would, I use to forget making changes to the Github repository and this use to go out of sync pretty quickly.

That is when I thought of creating symlinks. Now all the files stay in the Github repository directory and then [this installer script](https://github.com/surajssd/dotfiles/blob/master/installers/install-local-bin.sh) makes a symlink which is stored in `~/.local/bin`. Now when I make changes to the script, those changes are in fact, happening in the repository. And whenever I have time I `git commit` those changes and `git push` them to Github.

For making changes to the scripts I just have to do this:

```bash
vi $(which start-minikube)
```

### Local scripts

There are scripts that you want to have only locally. Like syncing code to a remote server. These are the scripts you don't want to share with the whole world. For this problem, I have added `.scripts` directory to the `PATH` variable in `~/.bashrc`. Now anywhere I can create `.scripts` directory, it is automatically in `PATH`.

```bash
$ cat ~/.bashrc | grep scripts
export PATH=$PATH:.scripts
```

Now with this foundational setup in place, whenever I have a project-specific script, I create a `.scripts` directory at the root of the project and put that bespoke script in that directory. So it is available for me from the root of the project directory.

Since I am creating such directories which are unrelated to the project and should not be committed. I have a [global entry for ignoring](https://github.com/surajssd/dotfiles/blob/master/configs/gitignore) `.scripts` directory.

```bash
# ignore the local scripts directory
.scripts
```

You can find my `~/.bashrc` file [here](https://github.com/surajssd/dotfiles/blob/master/configs/bashrc).

### Project Specific Scripts

There are specific scripts that you want to use only for a project. Now you might wonder why not contribute them to the project itself. There could be scripts to copy code to a remote server; you don't want to contribute such scripts to the project because they are particular to your workflow. In such a case, I have something called a project-specific `.scripts` directory in the root of the project. Read more about it in detail in this another blog post of mine [here](https://suraj.io/post/project-specific-scripts/).

## Managing random binaries

Now many projects ship their binaries off of their Github releases but don't have a package made for an operating system. Now packaging an application for every operating system could be a daunting task for the maintainers of the project, not everyone is willing to take that on their plate(I am grateful those maintainers already working on the open source project I don't expect them to do more work).

To manage binaries of such projects, you need your own mechanism of downloading the new versions and replacing older ones. For this again, I rely on my `~/.local/bin` directory. Here I put such downloaded binaries. And for the tools that I need regularly, I have created scripts for them. These scripts are managed as explained in the [**Global scripts**](#global-scripts) section.

For example, I use `helm` regularly, and I need it to be updated as new releases come. So I have [a script with following code snippet](https://github.com/surajssd/dotfiles/blob/master/local-bin/update-helm):

```bash
curl -LO https://get.helm.sh/helm-"${version}"-linux-amd64.tar.gz
tar -xvzf helm-"${version}"-linux-amd64.tar.gz
mv linux-amd64/helm ~/.local/bin/
```

Now in the above code snippet, I require the user to provide the version. But some tools have consistent naming off of the Github releases so for them I don't require the user to provide the version and finding version is automated as well. For example, the easiest way to find the latest version is using the Github API:

```bash
function get_latest_release() {
  version=$(curl --silent "https://api.github.com/repos/$1/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/')
}
```

And use above `function` like this in [my scripts](https://github.com/surajssd/dotfiles/blob/master/local-bin/update-minikube#L9):

```bash
get_latest_release bash/minikube
```

So if you compare the UX for both of them this is how it looks like. One that requires version:

```bash
$ update-helm v3.2.4
+ cd /tmp
+ curl -LO https://get.helm.sh/helm-v3.2.4-linux-amd64.tar.gz
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 12.3M  100 12.3M    0     0  3054k      0  0:00:04  0:00:04 --:--:-- 3055k
+ tar -xvzf helm-v3.2.4-linux-amd64.tar.gz
linux-amd64/
linux-amd64/helm
linux-amd64/README.md
linux-amd64/LICENSE
+ mv linux-amd64/helm /home/suraj/.local/bin/
```

One that does not require version:

```bash
$ update-minikube
Downloading minikube v1.12.1
Downloaded successfully in ~/.local/bin/
```

## Setting up a new machine

With all that framework in place, whenever I setup a new machine all I need to do is run following commands:

```bash
git clone https://github.com/surajssd/dotfiles
cd dotfiles
make install-all
```

That's it!

With this simplicity I get all the goodness of the scripts and since this repository also places my custom `~/.bashrc` I get all the aliases I use to be productive on shell.

## Conclusion

You can also setup a similar workflow for your scripts and binaries. This will provide you immense boost in productivity. Also if you have some better way to do same sripts and binaries management please share with me here or on Twitter. Happy Hacking!
