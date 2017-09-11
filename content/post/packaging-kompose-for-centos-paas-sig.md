+++
author = "Suraj Deshmukh"
date = "2017-03-15T14:16:43+05:30"
title = "Packaging 'kompose' for centos paas sig"
tags = ["centos", "rpm", "openshift", "fedora"]
categories = ["packaging", "notes", "kompose"]
description = ""

+++


**Note**: This is a living document and will be updated from time to time.

Following are steps to package kompose for [CentOS PAAS SIG](https://wiki.centos.org/SpecialInterestGroup/PaaS). CentOS PAAS SIG is a repository of packages where rpms related to OpenShift and eco-system around it are delivered.

## Setup your machine

Install packages needed

```bash
sudo yum update -y && \
sudo yum install -y epel-release && \
sudo yum install -y rpm-build go redhat-rpm-config make koji \
                    gcc byobu rpmlint rpmdevtools centos-packager
```

Setup certs

```bash
centos-cert -u surajd -n
```

## Make sure your rpmspec is error free

```bash
rpmlint kompose.spec
```

## Building kompose srpm

There are two ways to build `srpm` either build it locally or the ones that is built in koji for `epel`.

### Build rpms locally

Before you begin make sure you have setup the local directory structure:

```bash
rm -rf ~/rpmbuild/
mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
echo '%_topdir %(echo $HOME)/rpmbuild' > ~/.rpmmacros
```

Update the rpm spec and get source code using it.

```bash
spectool -g kompose.spec
```

Move the source to appropriate location

```bash
cp kompose-* ~/rpmbuild/SOURCES/
```

Start local build

```bash
rpmbuild -ba kompose.spec --define "dist .el7"
```

Once above exits with status code 0, you can find the `RPM`s:

```bash
$ ll ~/rpmbuild/RPMS/x86_64/
total 9724
-rw-rw-r--. 1 vagrant vagrant 9956072 May 26 09:37 kompose-0.7.0-0.1.el7.x86_64.rpm
```

`SRPM`s can be found at:

```bash
$ ll ~/rpmbuild/SRPMS/
total 4828
-rw-rw-r--. 1 vagrant vagrant 4941880 May 26 09:37 kompose-0.7.0-0.1.el7.src.rpm
```

See if dependencies are properly set

```bash
$ rpm -qpR ~/rpmbuild/RPMS/x86_64/kompose-*
git
libc.so.6()(64bit)
libc.so.6(GLIBC_2.2.5)(64bit)
libpthread.so.0()(64bit)
libpthread.so.0(GLIBC_2.2.5)(64bit)
libpthread.so.0(GLIBC_2.3.2)(64bit)
rpmlib(CompressedFileNames) <= 3.0.4-1
rpmlib(FileDigests) <= 4.6.0-1
rpmlib(PayloadFilesHavePrefix) <= 4.0-1
rpmlib(PayloadIsXz) <= 5.2-1
```

Try installing it locally and test it as mentioned in http://suraj.io/post/test-kompose/

### Pull sprm

For release 0.3.0, I pulled SRPM from:

```bash
wget https://kojipkgs.fedoraproject.org//packages/kompose/0.3.0/0.1.git135165b.el7/src/kompose-0.3.0-0.1.git135165b.el7.src.rpm
```

## Build the rpm on cbs from src.rpm

CBS is a community build system for SpecialInterestGroup members. It allows to build packages with Koji against CentOS5, CentOS6 and CentOS7.

### Trying a scratch build on CBS

Do a scratch build on CBS in `paas7-openshift-common-release`.

```bash
cbs build --scratch paas7-openshift-common-el7 ~/rpmbuild/SRPMS/kompose-*
```
You can download the rpm built here to test on CentOS machine.

### Making an actual release

```bash
cbs build paas7-openshift-common-el7 ~/rpmbuild/SRPMS/kompose-*
```

Once build is done successfully goto build page and download the rpm that is built for `x86_64`.

The page where builds were listed: https://cbs.centos.org/koji/taskinfo?taskID=181452
The page where this particular build happened and where I had download link to rpm: https://cbs.centos.org/koji/buildinfo?buildID=17249

```bash
wget http://cbs.centos.org/kojifiles/packages/kompose/0.7.0/0.1.el7/x86_64/kompose-0.7.0-0.1.el7.x86_64.rpm
```

Try to install this rpm and see if it works on CentOS:

```bash
yum install -y epel-release
yum install -y wget jq make

wget http://cbs.centos.org/kojifiles/packages/kompose/0.7.0/0.1.el7/x86_64/kompose-0.7.0-0.1.el7.x86_64.rpm

yum install -y kompose-0.7.0-0.1.el7.x86_64.rpm

git clone https://github.com/kubernetes-incubator/kompose/
cd kompose
make test-cmd
```

If everything is okay, Tag it into testing,
Verify that whatever you built last cbs is the good, the output should be version you wanted, and not the old one.

```bash
$ cbs latest-build paas7-openshift-common-candidate kompose
Build                                     Tag                   Built by
----------------------------------------  --------------------  ----------------
kompose-0.7.0-0.1.el7                     paas7-openshift-common-candidate  surajd
```

Tag the build output of above command to testing

```bash
$ cbs tag-pkg paas7-openshift-common-testing kompose-0.7.0-0.1.el7
Created task 181472
Watching tasks (this may be safely interrupted)...
181472 tagBuild (noarch): closed

181472 tagBuild (noarch) completed successfully
```

Verify it is in testing

```bash
$ cbs latest-build paas7-openshift-common-testing kompose
Build                                     Tag                   Built by
----------------------------------------  --------------------  ----------------
kompose-0.7.0-0.1.el7                     paas7-openshift-common-testing  surajd
```


Run whatever tests you want to verify that it's a good build.
It takes anywhere from 5 to 30 minutes for the rpm to make it into testing
http://buildlogs.centos.org/centos/7/paas/x86_64/openshift-origin/

```bash
yum -y install centos-release-openshift-origin
yum -y --enablerepo=centos-openshift-origin-testing install kompose
yum install -y epel-release
yum install -y jq make

git clone https://github.com/kubernetes-incubator/kompose/
cd kompose
make test-cmd
```

Check if the package is in testing

```bash
$ cbs latest-build paas7-openshift-common-testing kompose
Build                                     Tag                   Built by
----------------------------------------  --------------------  ----------------
kompose-0.7.0-0.1.el7                     paas7-openshift-common-testing  surajd
```

Tag it into release:

```bash
$ cbs tag-pkg paas7-openshift-common-release kompose-0.7.0-0.1.el7
Created task 181634
Watching tasks (this may be safely interrupted)...
181634 tagBuild (noarch): free
181634 tagBuild (noarch): free -> closed
  0 free  0 open  1 done  0 failed

181634 tagBuild (noarch) completed successfully
```

Once it is populated, it will show up in the repos, install it as follows:

```bash
yum install -y centos-release-openshift-origin
yum install -y kompose
```

## Ref:

- Install the SRPM and then Build from the Specfile https://wiki.centos.org/HowTos/RebuildSRPM
- Set Up an RPM Build Environment under CentOS https://wiki.centos.org/HowTos/SetupRpmBuildEnvironment
- [Kompose build instructions](https://github.com/dustymabe/fedpkg-kompose/blob/a3400c73843986693dbdc831de6de7f3a029f783/notes.txt)
- CentOS PaaS SIG https://wiki.centos.org/SpecialInterestGroup/PaaS
- CentOS SIGs https://wiki.centos.org/SpecialInterestGroup
- CBS https://wiki.centos.org/HowTos/CommunityBuildSystem
- [Building in CBS](https://wiki.centos.org/HowTos/CentosPackager)
- [RPM help from adb-utils repo](https://github.com/projectatomic/adb-utils/blob/master/README.adoc#steps-to-build-the-src-rpm)
