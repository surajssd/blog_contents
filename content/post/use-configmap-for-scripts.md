+++
author = "Suraj Deshmukh"
title = "Use Configmap for Scripts"
description = "A new way to ship scripts to container images."
date = "2020-08-22T21:00:51+05:30"
categories = ["kubernetes", "configuration", "bash", "notes"]
tags = ["kubernetes", "configuration", "notes"]
+++

We generally use some sort of scripts in application container images. They serve various purposes. Some scripts might do an initial setup before the application starts, others may have the whole logic of the container image, etc. Whatever the goal may be the general pattern is to copy the script into the container image, build the image and then the script is available when you consume the image.

## Cons of the Traditional Method

The round trip time during development and testing of such script is very long. You make some change to the script, you need to build the image, push it and then it is downloaded again. On an average for every change adds a couple of minutes to your feedback loop. Bash scripts are generally precarious in nature. You have to hammer it down, consider edge cases and thereby make it robust. This, of course, takes a lot of iterations. And with iterations comes the added time. So the question is, how do we reduce this feedback loop?

## Use Kubernetes Configmap for Scripts

Yes, put the scripts into Kubernetes Configmap. Let me explain. Instead of baking the script into the container image, put it into a configmap and then mount this configmap into the Kubernetes pod. Every time you make changes to the script, just update the configmap and kill the pod, so it picks up a new script from the configmap. The developmental round trip time now changes from a couple of minutes to a couple of seconds.

## Demo

Here we will see how to convert a traditionally built container image with a script to configmap based script delivery mechanism.

### Traditional Method

See the following directory structure. There is a helm chart in `echoscript` directory. Container image related configuration resides at the root of the project directory.

```bash
.
├── Dockerfile
├── echoscript
│   ├── Chart.yaml
│   ├── templates
│   │   └── deployment.yaml
│   └── values.yaml
└── run.sh

2 directories, 5 files
```

The script does not do anything fancy, just prints some text and then sleeps, this is good for demo purposes. The docker file builds an image based on `fedora:32` base.

```bash
$ cat Dockerfile
FROM fedora:32
COPY run.sh /
ENTRYPOINT [ "/run.sh" ]

$ cat run.sh
#!/bin/bash
echo "Hello from the script baked into the container"
echo "Sleeping for eternity!"
sleep infinity
```

Let us build and push the image so that when we deploy the chart, the image is pulled successfully: `docker build -t surajd/echoscript . && docker push surajd/echoscript`.

The deployment configuration is generic and there is nothing noteworthy in it.

```yaml
$ cat echoscript/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: echoscript
  labels:
    app: echoscript
spec:
  replicas: 1
  selector:
    matchLabels:
      app: echoscript
  template:
    metadata:
      labels:
        app: echoscript
    spec:
      containers:
      - name: echoscript
        image: surajd/echoscript
```

Deploy the chart using command `helm install test echoscript/` and see it working:

```bash
$ kubectl get pods
NAME                         READY   STATUS    RESTARTS   AGE
echoscript-f6499985c-tlr97   1/1     Running   0          57s

$ kubectl logs -f echoscript-f6499985c-tlr97
Hello from the script baked into the container
Sleeping for eternity!
^C
```

Now every time you want to make changes to the `run.sh` script you will have to go through the build push cycle.

### Configmap method

Look at this new directory structure. There is no `Dockerfile`. It is because the script does not need anything other than built-in stuff from a container image if you need specific packages to be installed then build a container image. Also, see that the script `run.sh` is moved to `scripts` directory in the helm chart.

```bash
.
└── echoscript
    ├── Chart.yaml
    ├── scripts
    │   └── run.sh
    ├── templates
    │   ├── configmap.yaml
    │   └── deployment.yaml
    └── values.yaml

3 directories, 5 files
```

There is a new configuration file called `configmap.yaml`. Look at the contents of that file:

```yaml
$ cat echoscript/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: scripts-configmap
data:
{{ (.Files.Glob "scripts/run.sh").AsConfig | indent 2 }}
```

So this will automatically load the `run.sh` from scripts directory into this configmap. I don't have to keep the bash script in a YAML file indented. In this way, I have the independence of editing and viewing file in its original format.

There are certain changes made to the deployment manifest as well. Like mentioned earlier there is no specially built image so I can use my base image from the Dockerfile as the container image here. Then there is a config to invoke this bash script. And then parameters to bring the file from configmap into the container image by using volume mount.

```diff
$ git diff echoscript/templates/deployment.yaml
diff --git echoscript/templates/deployment.yaml echoscript/templates/deployment.yaml
index 34fa7cb..3a10ca2 100644
--- echoscript/templates/deployment.yaml
+++ echoscript/templates/deployment.yaml
@@ -16,4 +16,13 @@ spec:
     spec:
       containers:
       - name: echoscript
-        image: surajd/echoscript
+        image: fedora:32
+        command: ["/bin/bash"]
+        args: ["/scripts-dir/run.sh"]
+        volumeMounts:
+        - name: scripts-vol
+          mountPath: /scripts-dir
+      volumes:
+      - name: scripts-vol
+        configMap:
+          name: scripts-configmap
```

Let's install it using command `helm install configmapmethod echoscript/` again and see the result:

```bash
$ kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
echoscript-6479bf46cd-8t2dj   1/1     Running   0          25s

$ kubectl logs -f echoscript-6479bf46cd-8t2dj
Hello from the script residing in helm chart.
Sleeping for eternity!
^C
```

Now let's make changes to the [`run.sh`](http://run.sh) file. I have modified the file to look something like this:

```bash
#!/bin/bash
echo "Hello from the script residing in helm chart."
echo "New line added here."
echo "Sleeping for eternity!"
sleep infinity
```

Now apply these changes by running the command `helm upgrade configmapmethod echoscript/`. And kill the pod using command `kubectl delete pod echoscript-6479bf46cd-8t2dj`. Now let's see if the new line shows up:

```bash
$ kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
echoscript-6479bf46cd-mzgn7   1/1     Running   0          38s

$ kubectl logs -f echoscript-6479bf46cd-mzgn7
Hello from the script residing in helm chart.
New line added here.
Sleeping for eternity!
^C
```

So you can see from making the change to witnessing its effects it took less than a couple of seconds.

## Cons of Configmap method

- **Platform:** The most significant assumption this method adds is that you are using Kubernetes.
- **Loose coupling:** If the container image is used in multiple places, this requires that the user should create corresponding configmaps and volume mount configs.
- **Ease of update:** If you are not using `helm` or `kustomize`, then making changes to the configmap can be cumbersome, well, you can always do something like this:

```bash
kubectl create cm scripts-configmap --from-file echoscript/scripts/run.sh \
                   --dry-run=client -o yaml | kubectl apply -f -
```

## Conclusion

Both approaches have their own pros and cons. But to harness the benefits of both methods, create one config during development and use something else in deployment. That way, you will have the best of both worlds. You will have a faster round trip time in the development phase, and you don't have to repeat the config in the deployment phase. Let me know what is your productivity hack with scripts when iterating on them in this container-dominant world. Happy Hacking!

## Links

- Repository with helm chart: [https://github.com/surajssd/echoscript](https://github.com/surajssd/echoscript).
