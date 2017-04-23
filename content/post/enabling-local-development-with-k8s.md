+++
author = "Suraj Deshmukh"
date = "2017-04-23T15:57:07+05:30"
title = "Enabling local development with Kubernetes"
description = "If you are doing development and wanna use kubernetes for it, then here is how you can do it."
categories = ["kubernetes"]
tags = ["kubernetes", "minikube", "development"]

+++

I wanna show how you can enable [Kubernetes](https://kubernetes.io/) in your day to day development workflow. So that
you get the feel of production deployment locally from day1.

I have a [flask application](http://flask.pocoo.org/) which I am working on. The basic directory structure looks like this:

```bash
$ ll
total 24
-rw-rw-r--. 1 foo foo  427 Apr 23 16:23 app.py
-rw-rw-r--. 1 foo foo  201 Apr 23 16:55 docker-compose.yml
-rw-rw-r--. 1 foo foo  363 Apr 23 16:21 Dockerfile
-rwxrwxr-x. 1 foo foo   82 Dec  5 19:41 entrypoint.sh
-rw-rw-r--. 1 foo foo 3010 Dec  5 19:41 README.adoc
-rw-rw-r--. 1 foo foo   11 Dec  5 19:41 requirements.txt
```

You can find all of these files in this [github repo](https://github.com/surajssd/hitcounter).

For having a local cluster I am using [minikube](https://github.com/kubernetes/minikube). So follow instructions to
[setup minikube](https://kubernetes.io/docs/getting-started-guides/minikube/). Once you follow the instructions
you will have a vm running a single node kubernetes cluster and a locally available `kubectl` binary.

Before running this application on the minikube cluster we need configurations that kubernetes understands. Since we
already have docker-compose file we will generate configs from this file with the help from tool called [kompose](http://kompose.io/).
Install kompose as per instructions as given on [docs](https://github.com/kubernetes-incubator/kompose#installation).

Generating configs:

```bash
$ mkdir configs
$ kompose convert -o configs/
WARN Kubernetes provider doesnt support build key - ignoring 
INFO file "configs/hitcounter-service.yaml" created 
INFO file "configs/redis-service.yaml" created    
INFO file "configs/hitcounter-deployment.yaml" created 
INFO file "configs/redis-deployment.yaml" created 
```

Before we deploy the app we need to make some changes in the deployment files that have `build` docker-compose construct
in them. In our case only python app `hitcounter` is built is being built from `Dockerfile`.

We will edit file `hitcounter-deployment.yaml` in `configs` directory, to not pull image but read image from the local docker
storage. Add a field after `image` called `imagePullPolicy: IfNotPresent`. Make changes as shown in following diff:

```diff
$ git diff
diff --git a/configs/hitcounter-deployment.yaml b/configs/hitcounter-deployment.yaml
index 7b1116d..0ef35b3 100644
--- a/configs/hitcounter-deployment.yaml
+++ b/configs/hitcounter-deployment.yaml
@@ -17,6 +17,7 @@ spec:
         - name: REDIS_HOST
           value: redis
         image: hitcounter
+        imagePullPolicy: IfNotPresent
         name: hitcounter
         ports:
         - containerPort: 5000
```

Now we are ready with the configs, but we need to build container image for our app. So here you will need to have
`docker-compose` installed on your machine. For that follow [docs here](https://docs.docker.com/compose/install/).

Build image in the minikube
```bash
eval $(minikube docker-env)
docker-compose build
```

Once the build is complete, we are good to the deployment in kubernetes.

```bash
$ kubectl create -f configs/
deployment "hitcounter" created
service "hitcounter" created
deployment "redis" created
service "redis" created
```

To verify that the app is running, find out the exposed IP Address as follows:

```bash
$ kubectl get svc
NAME         CLUSTER-IP   EXTERNAL-IP   PORT(S)          AGE
hitcounter   10.0.0.244   <pending>     5000:30476/TCP   6s
kubernetes   10.0.0.1     <none>        443/TCP          3d
redis        10.0.0.21    <none>        6379/TCP         6s
```

Now hit the externally exposed port `30476` of service `hitcounter` as:

```bash
$ curl $(minikube ip):30476
```

Now everytime you make changes to code do the following:

```bash
docker-compose build
kubectl scale deployment hitcounter --replicas=0
kubectl scale deployment hitcounter --replicas=1
```
Above we are removing all containers with old image and asking it to use the new image. For OpenShift we can do
`oc deploy hitcounter --latest` and it will trigger the deployment but I could not find anything similar with
kubernetes.

### Problems with minikube

If you face problem accessing the docker daemon running inside the minikube VM like one of this
```bash
$ eval $(minikube docker-env)
$ docker ps
could not read CA certificate "/etc/docker/ca.pem": open /etc/docker/ca.pem: no such file or directory
```

This could be because there is a mismatch in docker client and docker daemon version, so to solve this issue just copy
the docker client from the minikube VM to the local machine.

Enter the VM
```bash
minikube ssh
```

Copy the binary to host machine
```bash
scp $(which docker) foo@192.168.122.1:/home/foo/
```
Now put the binary in `PATH`.

### NOTE

The change we did in kubernetes deployment configs has enabled it to not pull image if the image is present in the docker's storage locally.
If you are running a build pipeline of your own then don't do this, because it might prevent you from pulling the
latest image. Also this will only work with the setup that is single node like minikube. For multi-node kubernetes
cluster you should setup a local container image registry that cluster can pull images from. And for every image build
push that image to registry.