+++
author = "Suraj Deshmukh"
date = "2019-06-10T11:57:07+05:30"
title = "Writing your own Seccomp profiles for Docker"
description = "Understanding the seccomp profile json format"
categories = ["docker", "security"]
tags = ["seccomp", "docker", "security"]
+++

## What is Seccomp?

> A large number of system calls are exposed to every userland process with many of them going unused for the entire lifetime of the process. A certain subset of userland applications benefit by having a reduced set of available system calls. The resulting set reduces the total kernel surface exposed to the application. System call filtering is meant for use with those applications. Seccomp filtering provides a means for a process to specify a filter for incoming system calls.

source: [Kernel Docs](https://www.kernel.org/doc/Documentation/prctl/seccomp_filter.txt)

## Seccomp with Docker

Seccomp profile is attached with docker container by [default](https://github.com/moby/moby/blob/master/profiles/seccomp/default.json). But understanding the profile can be hard if you are new to it.

Here is the snippet of syscalls allowed from the default profile:

```json
{
  "names": [
    "bpf",
    "clone",
    "fanotify_init",
    "lookup_dcookie",
    "mount",
    "name_to_handle_at",
    "perf_event_open",
    "quotactl",
    "setdomainname",
    "sethostname",
    "setns",
    "syslog",
    "umount",
    "umount2",
    "unshare"
  ],
  "action": "SCMP_ACT_ALLOW",
  "args": [],
  "comment": "",
  "includes": {
    "caps": [
        "CAP_SYS_ADMIN"
    ]
  },
  "excludes": {}
},
```

Here the syscalls mentioned in the `names` list are allowed for container only if the container starting has the capability `CAP_SYS_ADMIN` included when starting it, using the flag `--cap-add=SYS_ADMIN`.

## Experiment

I have done my own experiment where I am tying the `chmod` syscall to the capability `CAP_WAKE_ALARM` (There is no serious thinking put behind tying `chmod` to this capability `CAP_WAKE_ALARM`, I chose it because this capability did not seem to be doing much important hence I picked it up).

To try this out I have created a config of my own by changing the default config which looks like following diff:

```diff
--- default.json                2019-06-10 14:23:11.688170627 +0530
+++ chmod-wake-alarm.json       2019-06-10 14:19:25.706274172 +0530
@@ -62,7 +62,6 @@
                                "capget",
                                "capset",
                                "chdir",
-                               "chmod",
                                "chown",
                                "chown32",
                                "clock_getres",
@@ -94,8 +93,6 @@
                                "fallocate",
                                "fanotify_mark",
                                "fchdir",
-                               "fchmod",
-                               "fchmodat",
                                "fchown",
                                "fchown32",
                                "fchownat",
@@ -381,6 +378,22 @@
                },
                {
                        "names": [
+                               "chmod",
+                               "fchmod",
+                               "fchmodat"
+                       ],
+                       "action": "SCMP_ACT_ALLOW",
+                       "args": [],
+                       "comment": "",
+                       "includes": {
+                               "caps": [
+                                       "CAP_WAKE_ALARM"
+                               ]
+                       },
+                       "excludes": {}
+               },
+               {
+                       "names": [
                                "personality"
                        ],
                        "action": "SCMP_ACT_ALLOW",
@@ -791,4 +804,4 @@
                        "excludes": {}
                }
        ]
-}
\ No newline at end of file
+}
```

To understand what has changed I first removed all the references to the `chmod` and then added following snippet to tie the `chmod` to `CAP_WAKE_ALARM`.

```json
{
    "names": [
        "chmod",
        "fchmod",
        "fchmodat"
    ],
    "action": "SCMP_ACT_ALLOW",
    "args": [],
    "comment": "",
    "includes": {
        "caps": [
            "CAP_WAKE_ALARM"
        ]
    },
    "excludes": {}
},
```

Now let's try this if it works:

```bash
$ docker container run --rm -it --security-opt seccomp=chmod-wake-alarm.json alpine sh
/ # touch foo.sh
/ # chmod +x foo.sh
chmod: foo.sh: Operation not permitted
```

If you see with the newly created profile the container did not allow `chmod` to run.

```bash
$ docker container run --cap-add=WAKE_ALARM --rm -it --security-opt seccomp=chmod-wake-alarm.json alpine sh
/ # touch foo.sh
/ # chmod +x foo.sh
```

But in the above command I explicitly permitted this container to run with capability `CAP_WAKE_ALARM`, and now the container allows `chmod`. In this way you can create your own profile and tie it up with any capability you want.


## Reference

- [Docker Seccomp](https://docs.docker.com/engine/security/seccomp/)
- [Configs used in this experiment](https://gist.github.com/surajssd/2744e92e7da5892a85a6ec089a26042a)
- [Capabilities man page](http://man7.org/linux/man-pages/man7/capabilities.7.html)
- [What is seccomp?](https://en.wikipedia.org/wiki/Seccomp)
