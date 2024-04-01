---
author: "Suraj Deshmukh"
date: "2021-09-04T13:30:07+05:30"
title: "Certified Kubernetes Security Specialist CKS exam tips"
description: "Things to keep in mind to clear exam effortlessly."
draft: false
categories: ["kubernetes", "security", "cka", "cks"]
tags: ["kubernetes", "security", "cka", "cks"]
cover:
  image: "/post/2021/09/cks-tips/kubernetes-security-specialist-logo-300x285.png"
  alt: "cert"
---

I recently cleared the CKS certification exam. So it is incumbent upon me to help you navigate this stress-bound exam. All the tips that are provided are either from accrued knowledge or from personal experience.

![my cert](/post/2021/09/cks-tips/cks.png "my cert")

## Study Material

During the [study of CKA](https://suraj.io/post/road-to-cka/) almost three years ago, I studied everything from the documentation. Back then, the documentation had less content hence it was comprehensible. But now, to go through the entire documentation was not practical. So I did the [course by the killer.sh](https://killer.sh/r?d=cks-course). This course is rich in information, exercises and tries to explain the basics. At the end of each section in the course, the trainer provides resources to read more on the given topic. I would recommend going through each and every resource provided. Don't skip these. These resources will help you familiarize yourself with the Kubernetes documentation and support you during the exam.

Another good resource to study or read from is [Walid Shaari's Github repository](https://github.com/walidshaari/Certified-Kubernetes-Security-Specialist#cks-repo-topics-overview). It has a ton of resources I would highly recommend finishing those.

## Practice

- There are many ways to set up a single controller single worker Kubernetes cluster. I used Vagrant-VirtualBox to set up a single controller, two worker Kubernetes set up using kubeadm. You can find the Vagrantfile and instructions to use it [here](https://github.com/surajssd/cks-playground).
- Once you have gone through all the study material and are unsure if you are ready for the exam, then the simulator will help you gauge your progress.
- Once you buy the [killer.sh course](https://killer.sh/r?d=cks-course), you get access to the simulator.
- Another way to get access to the simulator is by buying the exam. Now you get access to the same simulator even by just purchasing the exam. I think CNCF and [killer.sh](http://killer.sh) has some kind of tie-up there.
- Official Kubernetes documentation does provide [ample resources](https://kubernetes.io/docs/tasks/administer-cluster/declare-network-policy/) to practice NetworkPolicies. But I found this [Github repository by Ahmet](https://github.com/ahmetb/kubernetes-network-policy-recipes) particularly helpful since it has various scenarios you can play with to better understand NetworkPolicies.
- Use `kubectl describe` with network policies to better understand them. Basic YAML configs could be confusing.
- In the exam, you have only one browser window open, which has a terminal and questions. It is helpful in the CKS exam to have multiple terminal windows to reduce cognitive load. To achieve this, you can use a tool like `tmux`. So while practicing for the exam, also practice `tmux` in your day-to-day work. To get started [here is a tmux cheatsheet](https://tmuxcheatsheet.com/).

## General Tips

- If you struggle with keeping up with the exam studies, then schedule the exam and work backward. This way, you won't have moving goalposts, and you will be forced to focus on your preparation.
- At any point, you are reading specific Kubernetes documentation, and you feel that the documentation can be helpful during the exam; just bookmark it. This is faster than searching the documentation during the exam.
- Here is a [Github gist](https://gist.github.com/surajssd/702c14eca6f4e8644d837b6e1c9ca0b7) with links to all the docs that I bookmarked for the exam.
- By heart, all the quick helper commands using `kubectl`. It has many generator commands that help you generate basic config, which can be used instead of fiddling with the YAML config from scratch. Most of such commands are documented in this [cheat sheet document](https://kubernetes.io/docs/reference/kubectl/cheatsheet/).
- As mentioned before, you can use `kubectl` to generate RBAC config as well. Practice creating RBAC config using `kubectl`. You should be able to generate `Role`, `Rolebinding`, `ClusterRole`, `ClusterRolebinding` using `kubectl` only. Follow [this doc](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#command-line-utilities) to learn these commands.
- Two weeks before the exam, become comfortable sitting for at least two hours uninterrupted at the exact same time as the exam. This helps prime your body to be comfortable on the day of the exam.
- If you don't know where the configs for a particular systemd service reside, use `systemctl cat <process name>` to find that. e.g., `systemctl cat kubelet`.

## Before exam Tips

- Disable `Ctrl + W` if you are used to that command on the terminal. On the terminal, this key combination is used to delete a word. But on a browser window, the same key combo could kill the exam window. Thus causing disturbances in your exam. If you are on Gnome-based Linux, [here](https://suraj.io/post/disable-ctrl-w/) is a simple way to disable the key combination. [This post](https://suraj.io/post/disable-ctrl-w/) explains setting up the command to a `noop`. On a typical desktop, windows manager takes precedence on the key combination. So once you set this key combination at that level, it stops working everywhere else.
- Clean the entire history of your browser. That way, any bookmark that you create does not conflict with your history.

## Exam Tips

- By heart the following config and set it up before the exam:
  - Create a `~/.vimrc` and enter the following config:

    ```bash
    set expandtab
    set tabstop=2
    set shiftwidth=2
    set paste
    ```

  - Update `~/.bashrc` with the aliases and auto-completion:

    ```bash
    source <(kubectl completion bash)
    alias k=kubectl
    complete -F __start_kubectl k

    alias kg='kubectl get'
    alias kgp='kubectl get pods'
    alias kl='kubectl logs -f'
    alias kd='kubectl describe'
    export do="--dry-run=client -o yaml"
    export del="--wait=0 --timeout=0 --force"

    change-ns ()
    {
        kubectl config set-context $(kubectl config current-context) --namespace $1
    }
    ```

    **NOTE**: Use the aliases of your choice. These are what I use. You can copy the auto-completion config during the exam from these [k8s docs here](https://kubernetes.io/docs/reference/kubectl/cheatsheet/#bash).

- During the exam, whenever a question is presented to you. The question also gives you a command to change the context. Along with changing the context using the command provided, also switch to the appropriate namespace. This reduces the time to type `-n namespace-name` on every namespaced command. It also reduces the anxiety of wondering if you typed the command in the correct namespace. Add the following alias to the exam terminal's `.bashrc`.

    ```bash
    change-ns ()
    {
        kubectl config set-context $(kubectl config current-context) --namespace $1
    }
    ```

- I followed a mantra of not solving anything that has weightage less than equal to 5%. I use to flag these low-weightage questions to solve later.

## Conclusion

I hope you find these tips helpful. And all the best with your exam!
