---
author: "Suraj Deshmukh"
date: "2021-06-19T16:16:00+05:30"
title: "How to create a Systemd daemon quickly?"
description: ""
draft: false
categories: ["linux", "systemd"]
tags: ["linux", "systemd"]
images:
- src: "/post/2021/06/systemd-service/systemd.png"
  alt: "Systemd"
---

If you have a script or a binary and want to run it as a Systemd service, keep following. This blog will show you how to take any such executable code and run it using Systemd. Sure, you can do similar stuff using Docker as well. Although there are certain downsides of using Docker (alone) for managing the daemons. Systemd is good at log management on the node over a Docker container. If a container fails, you may or may not have access to the logs. Systemd provides constructs in managing dependencies quite well. And finally, you may not be using Docker on the machine, while Systemd is quite ubiquitous on any Linux.

# Steps

## Binary

```bash
export BIN_PATH=/absolute/path/to/the/binary
```

Ensure that the binary is executable:

```bash
chmod +x "${BIN_PATH}"
```

## Systemd service file

Provide the name you wish to assign to this service (use [kebab-case](https://en.wikipedia.org/wiki/Letter_case#Special_case_styles)):

```bash
# e.g. export SVC_NAME="my-app"
export SVC_NAME="name-of-the-service"
```

Now create a Systemd service file. Service files contain configuration pertaining to a daemon. Here you specify all the things that the Systemd needs, e.g. path to the binary, its dependencies, how often do you restart, etc.

```bash
echo "
[Unit]
Description=${SVC_NAME}
[Service]
ExecStart=${BIN_PATH}
Restart=always
RestartSec=5
[Install]
" | tee /etc/systemd/system/${SVC_NAME}.service
```

**NOTE**: If there are dependencies for this executable code, then you can add `Requires=dep.service` and `After=dep.service` under the `[Unit]` section of the service file.

## Start the process

Run the following commands to start the process:

```bash
systemctl daemon-reload

# Start the process right now and enable it to run on reboot.
systemctl enable --now "${SVC_NAME}"
systemctl status --no-pager "${SVC_NAME}"
journalctl -fu "${SVC_NAME}"
```

## Watch logs

Execute the following command to see the logs of the process:

```
journalctl -u "${SVC_NAME}"
```

# Conclusion

That’s it. It is that easy to convert any binary into a Systemd service.
