+++
author = "Suraj Deshmukh"
title = "Testing 'fedora' and 'CentOS' kompose package"
date = "2017-03-14T00:31:57+05:30"
tags = ["centos", "fedora", "rpm"]
categories = ["packaging", "notes", "kompose"]
+++

I generally do `kompose` package testing for `fedora` and `CentOS`. So here are the steps I follow.

## Fedora

For respective fedora version use the tag respectively for e.g. `25` for `fedora 25`.

Starting the environment:

```bash
docker run -it registry.fedoraproject.org/fedora:26 bash
```

Running tests:

```bash
# Inside the container
# Pull packages from the testing repository
dnf --enablerepo updates-testing -y install kompose

# Check the kompose version
kompose version

# Install the testing dependencies
dnf install -y jq make

# Pull the git repository to run the functional tests
git clone https://github.com/kubernetes-incubator/kompose/
cd kompose

# Run cmd tests
make test-cmd

```

## CentOS `epel` repo

Spin the CentOS environment in container.

```bash
docker run -it centos bash
```

Running tests:

```bash
# Install kompose from 'epel-testing' repo
yum install -y epel-release
yum --enablerepo=epel-testing -y install kompose

# Install the testing dependencies
yum install -y jq make

# Pull the git repository to run the functional tests
git clone https://github.com/kubernetes-incubator/kompose/
cd kompose

# Run cmd tests
make test-cmd

```

## CentOS `paas7-openshift-common-el7` repo

Spin the CentOS environment in container.

```bash
docker run -it centos bash
```

Running tests:

```bash
# For pulling package from testing repo in CentOS PAAS sig
yum -y install centos-release-openshift-origin
yum -y --enablerepo=centos-openshift-origin-testing install kompose

# Install the testing dependencies
yum install -y epel-release
yum install -y jq make

# Pull the git repository to run the functional tests
git clone https://github.com/kubernetes-incubator/kompose/
cd kompose

# Run cmd tests
make test-cmd

```

If all tests pass then just give a karma for it on the release page.

## Ref:

- [Original article on Github](https://github.com/surajssd/blog_contents/blob/master/content/post/test-kompose.md)
- [Getting the latest fedora docker images](https://github.com/fedora-cloud/docker-brew-fedora/issues/44)
- [Fedora docker hub page](https://hub.docker.com/_/fedora/)
