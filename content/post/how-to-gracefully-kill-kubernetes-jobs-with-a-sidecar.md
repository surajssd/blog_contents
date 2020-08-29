+++
author = "Suraj Deshmukh"
title = "How to gracefully kill Kubernetes Jobs with a sidecar?"
description = "A sidecar in a Kubernetes Job, what? Yeah you might need one and here is how to shut it."
date = "2020-08-29T15:33:51+05:30"
categories = ["kubernetes", "configuration", "jobs", "notes"]
tags = ["kubernetes", "configuration", "notes"]
+++

Have you ever had a sidecar in your Kubernetes Job? If no, then trust me that you are lucky. If yes, then you will have the frustration of your life. The thing is Kubernetes Jobs are meant to exit on completion. But if you have a long-running sidecar, then that might twist things for Kubernetes and in turn of you.

Why would you even want a sidecar for Job? Well, one of the most prevalent use case is when using service mesh proxy. There could be something else as well like metrics endpoint, log collection or whatever. Given the complexity and heterogeneity of the workloads, there could be any kind of use case that involves having sidecar for a Job pod.

This blog post will showcase how to cleanly exit from a Job pod if you have a long-running sidecar.

## Normal Job

Let's see how a normal Job workflow looks like. I have a Job that runs the following script:

```bash
#!/bin/bash

for num in $(seq 10 -1 1); do
  echo $num
  sleep 1
done

echo "And it is a lift off!"
```

See the above script in the Github repository [here](https://github.com/surajssd/kill-jobpod-with-sidecar/blob/5cff292a822c56bb9c2930e4f0e82e16b1a31340/job/scripts/run.sh).

And the Kubernetes Job configuration looks like this:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: foojob
  namespace: default
spec:
  template:
    spec:
      restartPolicy: OnFailure
      containers:
      - name: foojob
        image: fedora:32
        command: ["/bin/bash"]
        args: ["/scripts-dir/run.sh"]
        volumeMounts:
        - name: scripts-vol
          mountPath: /scripts-dir
      volumes:
      - name: scripts-vol
        configMap:
          name: scripts-configmap
```

See the full definition of the Job configuration [here](https://github.com/surajssd/kill-jobpod-with-sidecar/blob/5cff292a822c56bb9c2930e4f0e82e16b1a31340/job/templates/deployment.yaml). To understand why the Job configuration has `volumes` and `volumeMounts`, read [my other blog](https://suraj.io/post/use-configmap-for-scripts/) where I explain how configmaps are the best way to use inject scripts into containers.

A typical run of above will look like this:

```bash
$ helm install --generate-name job/
NAME: job-1598685079
LAST DEPLOYED: Sat Aug 29 12:41:19 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None

$ kubectl get pods
NAME           READY   STATUS              RESTARTS   AGE
foojob-86rlf   0/1     ContainerCreating   0          1s

$ kubectl logs foojob-86rlf
10
9
8
7
6
5
4
3
2
1
And it is a lift off!

$ kubectl get pods
NAME           READY   STATUS      RESTARTS   AGE
foojob-86rlf   0/1     Completed   0          14s
```

So pod exits with `STATUS` field set to `Completed`.

## What happens when a Job has Sidecar?

To add a sidecar to our existing Job I added a container which just sleeps forever. See following diff to understand what has changed:

```diff
diff --git job/templates/job.yaml job/templates/job.yaml
index 04e7175..1bb5a08 100644
--- job/templates/job.yaml
+++ job/templates/job.yaml
@@ -9,6 +9,10 @@ spec:
     spec:
       restartPolicy: OnFailure
       containers:
+      - name: endlesssidecar
+        image: fedora:32
+        command: ["/bin/bash"]
+        args: ["-c", "sleep infinity; echo 'stopping now!'"]
       - name: foojob
         image: fedora:32
         command: ["/bin/bash"]
```

See the new full configuration of Job manifest [here](https://github.com/surajssd/kill-jobpod-with-sidecar/blob/80dd2e8d485c62f62ff1de67d6c5128c07c6fba0/job/templates/deployment.yaml#L12-L15).

> **NOTE:** In your case, it could be any other sidecar, for illustration purposes I have added a dummy sidecar.

Now let's see the full run of this setup:

```bash
$ helm install --generate-name job/
NAME: job-1598685624
LAST DEPLOYED: Sat Aug 29 12:50:25 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None

$ kubectl get pods
NAME           READY   STATUS              RESTARTS   AGE
foojob-kd9sl   0/2     ContainerCreating   0          1s

$ kubectl logs foojob-kd9sl foojob
10
9
8
7
6
5
4
3
2
1
And it is a lift off!

$ kubectl get pods
NAME           READY   STATUS     RESTARTS   AGE
foojob-kd9sl   1/2     NotReady   0          21s
```

If you see everything went fine in the `foojob` container of the Job pod. But the pod `STATUS` has changed to `NotReady`. This is because one container has stopped successfully, and the other is still running. This is the problem with sidecar in the Job. Now Kubernetes does not concede this as `Completed` because not all containers have stopped in the pod.

## Job Sidecar with unique setup!

Since the long running sidecar does not stop gracefully, we should make sure that it is halted. So the onus is on the `foojob` to kill the long running sidecar. So this is what I have added to our simple script:

```diff
diff --git job/scripts/run.sh job/scripts/run.sh
index 8fed959..5932149 100755
--- job/scripts/run.sh
+++ job/scripts/run.sh
@@ -6,3 +6,6 @@ for num in $(seq 10 -1 1); do
 done

 echo "And it is a lift off!"
+
+pkill sleep
+true
```

But have you realised how does a script running in one container has access to the process in another container? Well, we have a Kubernetes native answer to that: `shareProcessNamespace`. Here is what it mean straight from the docs:

> `Share a single process namespace between all of the containers in a pod. When this is set containers will be able to view and signal processes from other containers in the same pod, and the first process in each container will not be assigned PID 1. HostPID and ShareProcessNamespace cannot both be set.`

In simple terms set the field `shareProcessNamespace` to `true` in `pod.spec` and all containers now share the process namespace and can see each other. Due to this enablement `pkill sleep` from the `foojob` container can kill its sidecar or sidecar's main process.

Here is the diff from the Job YAML file:

```diff
diff --git job/templates/job.yaml job/templates/job.yaml
index 1bb5a08..61d75cf 100644
--- job/templates/job.yaml
+++ job/templates/job.yaml
@@ -7,14 +7,15 @@ metadata:
 spec:
   template:
     spec:
+      shareProcessNamespace: true
       restartPolicy: OnFailure
       containers:
         command: ["/bin/bash"]
       - name: foojob
-        image: fedora:32
+        image: surajd/fedora32-pgrep
         command: ["/bin/bash"]
         args: ["/scripts-dir/run.sh"]
         volumeMounts:
```

The image has been changed from plain `fedora:32` to `surajd/fedora32-pgrep` because the default fedora image does not ship `pkill` so I installed the package `procps` and now all the "process-killing" tools are available in the new docker image. See the dockerfile [here](https://github.com/surajssd/kill-jobpod-with-sidecar/blob/master/Dockerfile).

Now let's see this in operation:

```bash
$ helm install --generate-name job/
NAME: job-1598689001
LAST DEPLOYED: Sat Aug 29 13:46:41 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None

$ kubectl get pods
NAME           READY   STATUS              RESTARTS   AGE
foojob-wr9hl   0/2     ContainerCreating   0          1s

$ kubectl logs foojob-wr9hl foojob
10
9
8
7
6
5
4
3
2
1
And it is a lift off!

$ kubectl logs foojob-wr9hl endlesssidecar
Terminated
stopping now!

$ kubectl get pods
NAME           READY   STATUS      RESTARTS   AGE
foojob-wr9hl   0/2     Completed   0          32s
```

If you notice there is output from the sidecar as well, it first says `Terminated` which is as a result of the `pkill` we added. So that is the easiest way to kill the sidecar and satisfy Kubernetes.

## Upstream efforts

- There is an issue in Kubernetes upstream for this, find it [here](https://github.com/kubernetes/kubernetes/issues/25908).
- A KEP is present [here](https://github.com/kubernetes/enhancements/issues/753).
- And this blog is very much inspired by this [comment](https://github.com/linkerd/linkerd2/issues/1869#issuecomment-595456178).

## Conclusion

We will just have to wait until we have the upstream with better support to segregate sidecar from primary containers in the pod. So until then, this hack is all we've got. You can find all the configuration used in this blog [here](https://github.com/surajssd/kill-jobpod-with-sidecar).
