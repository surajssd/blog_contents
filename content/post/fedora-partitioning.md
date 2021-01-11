+++
author = "Suraj Deshmukh"
title = "Linux Partitioning Guide"
description = "How to create partitions for Linux?"
date = "2021-01-11T17:00:51+05:30"
categories = ["linux", "fedora"]
tags = ["linux", "fedora", "sysadmin"]
+++

I use Fedora Linux as my primary desktop OS. Every time there is a fresh install, I find myself confounded on how to partition the OS. So I thought I might as well make a permanent note of how I do it so that I always have a place to come back to.

![Fedora](/images/fedora-partitioning/fedoralogo.png "Fedora")

## Partitioning Scheme

This is how I partition my Fedora during installation:

| Partition | Mounted On  | Size              | Encrypted | Filesystem |
|-----------|-------------|-------------------|-----------|------------|
| Boot      | `/boot`     | 512M              | No        | `ext4`     |
| Boot EFI  | `/boot/efi` | 200M              | No        | `vfat`     |
| Swap      | -           | 1.5 times the RAM | Yes       | `swap`     |
| Home      | `/home`     | 265G              | Yes       | `ext4`     |
| Root      | `/`         | 211G              | No        | `ext4`     |

## Encryption

Note that `Swap` and `Home` partitions have to be encrypted. `Swap` extends the RAM and can have a sensitive copy of RAM data like passwords, keys, etc. Hence always ensure to encrypt the `Swap` partition. `Home` partition is equally essential to be encrypted because this is where your data will live. Things like configuration, SSH keys, GPG keys, API keys are all stored in the home in various directories. So it is of utmost importance that you encrypt these two directories.

## Size

My disk size is 512G. I have divided `Home` and `Root` as per convenience. So depending on your usage of each partition you can decide what is best for you.

I hope you find this sort of partitioning scheme helpful. It has worked for me for the past five years.
