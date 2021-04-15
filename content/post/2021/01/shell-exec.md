+++
author = "Suraj Deshmukh"
title = "Exec in container environment"
description = "The correct way to use exec and the signal passing."
date = "2021-01-23T10:10:41+05:30"
categories = ["kubernetes", "containers", "bash"]
tags = ["kubernetes", "containers", "bash"]
+++

If you use `exec` in your container script, then the container or Kubernetes pod might exit after the command that is exec-ed into has exited. But if that's what you wanted, then it's okay. This blog tries to explain how to pass the signals to the applications, how they work differently when invoked uniquely and what to do if the application does handle them.

## What are the "Signals"?

Signals are messages one process can send to another process, mostly used in UNIX like operating systems.

## How exec works in Linux?

This is copied from the man page:

![Exec Man Page](/post/2021/01/shell-exec/1-exec.png "Exec Man Page")

## An application spawned by a shell script.

To ensure that the signals are passed effectively to the real application, spawned by a shell script, you can do something similar to what is done in this snippet. Use `trap` to call a function which does the cleanup after receiving any of the registered signals like `SIGHUP`, `SIGTERM` or `SIGINT`.

```bash
#!/bin/bash

function cleanup() {
  kill "${pid}"
  exit
}

trap cleanup SIGHUP SIGTERM SIGINT

echo "sleeping"
sleep infinity &
pid="${!}"

wait "${!}"
```

If a process runs in foreground spawned by a bash script, then the bash script does not respond to the signals, so the `trap` is rendered useless. Hence run it in the background and wait on it using `wait`.
Make sure that the script is run via `ENTRYPOINT` the way it is done in this `Dockerfile`:

```docker
FROM quay.io/surajd/fedora-networking

COPY ./cleanup.sh /cleanup.sh

ENTRYPOINT /cleanup.sh
```

Since the above script, `cleanup.sh` is listening on three types of signals: `SIGHUP`, `SIGTERM`, `SIGINT` if any of these is sent to the script the container will stop working. So the following commands will work just fine:

![Docker commands](/post/2021/01/shell-exec/4-docker-commands.png "Docker commands")

Here is a video that shows how the above commands works:

{{<youtube IygRbOeJPGQ>}}

## An application spawned directly.

Here is a golang application that handles signals. This golang app can be run directly via `ENTRYPOINT`.

![Golang Signals App](/post/2021/01/shell-exec/5-golang-code.png "Golang Signals App")

```docker
FROM quay.io/surajd/fedora-networking

COPY ./signals /signals

ENTRYPOINT /signals
```

This golang code is also listening on the same signals: `SIGHUP`, `SIGTERM`, `SIGINT`. The code has a main goroutine which spawns another goroutine. The background goroutine is listening to the aforementioned signals. While the main goroutine is waiting (`←done`) for the background goroutine to receive signal and finally exit. In the `Dockerfile`, we have simply copied the binary directly and spawn it using `ENTRYPOINT`, this ensures that the application receives the signals directly. `ENTRYPOINT` is actually starting the given process using `exec`.

Watch the video below, which shows how the signals are passed to the application:

{{<youtube z60M7FwYFJM>}}

## When should you use `exec`?

Now consider that you have an application which listens to those signals, but for some reason, you need to spawn that application via a shell script. This is when you use `exec`. We are using the same golang application as before but spawning it from a bash script. Notice that this script is invoking that golang binary using `exec`, this replaces the bash script with golang binary as `PID 1`.

```bash
#!/bin/bash

echo "spawning the golang app"

# This app can handle the signals so no need to handle them on
# behalf of the application here in the bash script.
exec ./signals
```

```docker
FROM quay.io/surajd/fedora-networking

COPY ./signals /signals
COPY ./startup.sh /startup.sh

ENTRYPOINT /startup.sh
```

If we get shell access of the container, you will see that the golang `signals` app has become `PID 1`.

![Console output](/post/2021/01/shell-exec/9-console-output.png "Console output")

Here is the video that shows these signals passing in action:

{{<youtube r8QWTeFm4QY>}}

## Conclusion

I hope this gives you some clearer picture on how to use `exec` sanely and make sure that the applications are spawned correctly to get the signals sent by their environment be it systemd, docker or Kubernetes.

## References

- [Signal IPC](https://en.wikipedia.org/wiki/Signal_(IPC)).
- [Bash does not process signals until foreground process returns.](http://mywiki.wooledge.org/SignalTrap#When_is_the_signal_handled.3F)
- [Handling signals with `sleep`.](https://unix.stackexchange.com/questions/478563/sleep-wait-and-ctrlc-propagation)
- [Docker `ENTRYPOINT` and signal handling.](https://docs.docker.com/engine/reference/builder/#entrypoint)
- [List of signals you can send to your application.](https://bash.cyberciti.biz/guide/Sending_signal_to_Processes)
- [How to use `trap` in your bash script.](https://linuxcommand.org/lc3_wss0150.php)
- [How signal handlers work?](https://stackoverflow.com/a/53410546/3848679)
- [Code snippets used in this blog.](https://github.com/surajssd/exec-into-container-blog)
