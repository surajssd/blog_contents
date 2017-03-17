+++
author = "Suraj Deshmukh"
date = "2017-03-15T14:16:43+05:30"
title = "Packaging 'kompose' for centos paas sig"
tags = ["centos", "rpm", "openshift"]
categories = ["packaging"]
description = ""

+++

Following are steps to package kompose for CentOS pass SIG.

**Note**: This is a living document and will be updated from time to time.

For release 0.3.0

Pull sprm

```
$ wget https://kojipkgs.fedoraproject.org//packages/kompose/0.3.0/0.1.git135165b.el7/src/kompose-0.3.0-0.1.git135165b.el7.src.rpm
```

Build the rpm on cbs from src.rpm

```
$ cbs build paas7-openshift-common-el7 ./kompose-0.3.0-0.1.git135165b.el7.src.rpm
```

Once build is done successfully goto build page and download the rpm that is built for x86_64


The page where builds were listed: https://cbs.centos.org/koji/taskinfo?taskID=169117
The page where this particular build happened and where I had download link to rpm: https://cbs.centos.org/koji/buildinfo?buildID=16681

```
wget http://cbs.centos.org/kojifiles/packages/kompose/0.3.0/0.1.git135165b.el7/x86_64/kompose-0.3.0-0.1.git135165b.el7.x86_64.rpm
```

- Try to install this rpm and see if it works on CentOS:


```
yum install -y epel-release
yum install -y wget jq make

wget http://cbs.centos.org/kojifiles/packages/kompose/0.3.0/0.1.git135165b.el7/x86_64/kompose-0.3.0-0.1.git135165b.el7.x86_64.rpm

yum install -y kompose-0.3.0-0.1.git135165b.el7.x86_64.rpm

git clone https://github.com/kubernetes-incubator/kompose/
cd kompose
make test-cmd
```

If everything is okay, Tag it into testing,
Verify that whatever you built last cbs is the good, the output should be version you wanted, and not the old one.

```
$ cbs latest-build paas7-openshift-common-candidate kompose
Build                                     Tag                   Built by
----------------------------------------  --------------------  ----------------
kompose-0.3.0-0.1.git135165b.el7          paas7-openshift-common-candidate  surajd

```



Tag the build output of above command to testing

```
$ cbs tag-pkg paas7-openshift-common-testing kompose-0.3.0-0.1.git135165b.el7
Created task 169130
Watching tasks (this may be safely interrupted)...
169130 tagBuild (noarch): open (x86_64-4.cbs.centos.org)
169130 tagBuild (noarch): open (x86_64-4.cbs.centos.org) -> closed
  0 free  0 open  1 done  0 failed

169130 tagBuild (noarch) completed successfully
```


Verify it is in testing

```
$ cbs latest-build paas7-openshift-common-testing kompose
Build                                     Tag                   Built by
----------------------------------------  --------------------  ----------------
kompose-0.3.0-0.1.git135165b.el7          paas7-openshift-common-testing  surajd
```


- Run whatever tests you want to verify that it's a good build.
  It takes anywhere from 5 to 30 minutes for the rpm to make it into testing
  http://buildlogs.centos.org/centos/7/paas/x86_64/openshift-origin/

```
yum -y install centos-release-openshift-origin
yum -y --enablerepo=centos-openshift-origin-testing install kompose
yum install -y epel-release
yum install -y jq make

git clone https://github.com/kubernetes-incubator/kompose/
cd kompose
make test-cmd
```

Check if the package is in testing

```
$ cbs latest-build paas7-openshift-common-testing kompose
Build                                     Tag                   Built by
----------------------------------------  --------------------  ----------------
kompose-0.3.0-0.1.git135165b.el7          paas7-openshift-common-testing  surajd
```

Tag it into release:

```
$ cbs tag-pkg paas7-openshift-common-release kompose-0.3.0-0.1.git135165b.el7
Created task 169131
Watching tasks (this may be safely interrupted)...
169131 tagBuild (noarch): free
169131 tagBuild (noarch): free -> closed
  0 free  0 open  1 done  0 failed

169131 tagBuild (noarch) completed successfully
```

