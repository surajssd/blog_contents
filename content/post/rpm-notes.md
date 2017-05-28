+++
categories = ["packaging", "notes"]
tags = ["centos", "rpm", "fedora"]
date = "2017-03-24T10:35:54+05:30"
author = "Suraj Deshmukh"
description = "General notes about rpm packaging and references to upstream docs"
title = "rpm Notes"

+++

## Setup of the system for building rpms

```bash
$ dnf -y install fedora-packager fedora-review
$ sudo usermod -a -G mock vagrant
$ fedora-packager-setup
$ kinit surajd@FEDORAPROJECT.ORG
```

## My Notes


- Start reading from: [Fedora packager's guide](https://docs.fedoraproject.org/en-US/Fedora_Draft_Documentation/0.1/html/Packagers_Guide/index.html)
- Some macros come from `redhat-rpm-config` and `fedora-rpm-macros`.

```bash
$ sudo rpm -ql redhat-rpm-config-45-1.fc25.noarch
```

- To see all macros on the system:

```bash
$ rpm --showrc
```

- Koji - fedora build system
- `fedora` uses `fedpkg` for doing builds, while `rpmbuild` is for `CentOS`
- To get general info about the package

```bash
$ rpm -qip ./x86_64/namaskar-1-1.fc25.x86_64.rpm
```

OR

```bash
$ less namaskar-1-1.fc25.src.rpm
```

- To see what are the dependencies of the package

```bash
$ rpm -qp --requires ./noarch/namaskar-1-1.fc25.noarch.rpm
/bin/bash
rpmlib(CompressedFileNames) <= 3.0.4-1
rpmlib(FileDigests) <= 4.6.0-1
rpmlib(PayloadFilesHavePrefix) <= 4.0-1
rpmlib(PayloadIsXz) <= 5.2-1
```

- To see what packages include your package as dependency

```bash
$ rpm -qp --provides ./noarch/namaskar-1-1.fc25.noarch.rpm
namaskar = 1-1.fc25
```

- After you think the spec is ready and before you push it to build

```bash
$ fedpkg --release f25 lint
```

- Doing local mock build

```bash
$ fedpkg --release f25 mockbuild
```

- Doing build in fedora build system, koji

```bash
$ fedpkg --release f25 scratch-build --target f25 --srpm
```

- Running fedora-review

```bash
$ fedpkg --release f25 srpm
$ fedora-review -n namaskar
```

- Decompress a package, [src](https://docs.fedoraproject.org/en-US/Fedora_Draft_Documentation/0.1/html/Packagers_Guide/sect-Packagers_Guide-Format_of_the_Archived_Files.html).

```bash
$ rpm2cpio kompose-0.1.0-0.1.git8227684.el7.src.rpm | cpio -ivdm
```

**OR**

```bash
$ rpmdev-extract kompose-0.4.0-0.1.git4e3300c.fc27.x86_64.rpm
```

- Various ways to query package: [src](https://docs.fedoraproject.org/en-US/Fedora_Draft_Documentation/0.1/html/Packagers_Guide/sect-Packagers_Guide-Querying_Packages.html).
- To download source as mentioned in the `Source0` tag, use:

```bash
$ spectool -g kompose.spec
```

- To validate the rpmspec if it is error free

```bash
$ rpmlint kompose.spec
```

## Ref:

- Yum and RPM Tricks https://wiki.centos.org/TipsAndTricks/YumAndRPM
- Creating RPM Packages with Fedora https://fedoraproject.org/wiki/How_to_create_an_RPM_package
- Inside the Spec File, Directives For the `%files` list http://ftp.rpm.org/max-rpm/s1-rpm-inside-files-list-directives.html
- How to get sponsored into the packager group https://fedoraproject.org/wiki/How_to_get_sponsored_into_the_packager_group
- [Doing local builds help from adb-utils repo](https://github.com/projectatomic/adb-utils/blob/master/README.adoc#steps-to-build-the-src-rpm)
- Using Mock to test package builds https://fedoraproject.org/wiki/Using_Mock_to_test_package_builds
- Packaging:RPMMacros https://fedoraproject.org/wiki/Packaging:RPMMacros?rd=Packaging/RPMMacros
- [Tweet about using `rpmdev-extract`](https://twitter.com/carlwgeorge/status/846892384570916866)
