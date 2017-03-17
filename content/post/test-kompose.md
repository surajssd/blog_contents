+++
author = "Suraj Deshmukh"
title = "Testing 'fedora' and 'CentOS' kompose package"
date = "2017-03-14T00:31:57+05:30"
tags = ["centos", "fedora"]
categories = ["packaging"]
+++

I generally do `kompose` package testing for fedora and CentOS. So here are the steps I follow.

**Note**: All the commands that start with `#` are inside the container.

## Fedora

Spin the fedora test environment, let's say fedora 25, I do it in containers.

```bash
$ docker run -it fedora:25 bash
```

Once inside the container download the latest package from the testing repo:

```bash
# dnf --enablerepo updates-testing -y install kompose
```

**Note**: Make sure you download the latest release, there might be conditions that you download the old package.

Now having the package is not enough, we need to run the functional tests, which is in the source repoistory. But before we clone the repo, we need some dependencies like `make` and `jq`. So install them using packages.

```bash
# dnf install -y jq make
```

## CentOS

Spin the CentOS environment in container.

```bash
$ docker run -it centos bash
```

Install kompose from `epel-testing` repo:

```bash
# yum --enablerepo=epel-testing -y install kompose
```

And packages needed to run tests:

```bash
# yum install -y jq make
```

## Functional tests

Now lets get the functional tests:

```
# git clone https://github.com/kubernetes-incubator/kompose/
# cd kompose
```

Run tests:

```bash
# make test-cmd
```

If all tests pass then just give a karma for it on the release page.

