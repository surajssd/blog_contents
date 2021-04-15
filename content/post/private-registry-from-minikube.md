+++
author = "Suraj Deshmukh"
title = "Using private container registries from minikube"
date = "2017-10-06T19:32:33+05:30"
description = "A guide to how would you download image from private container registry in minikube"
categories = ["kubernetes", "minikube", "containers"]
tags = ["kubernetes", "minikube", "containers"]
+++

I am doing Kubernetes native development using minikube. And for doing that I had to
download a Container image that is available in internally hosted private container registry.

On the configuration side of doing that you will need to create Kubernetes Secret of type
`docker-registry`. And now refer that secret you just created in your Pod manifest under
`pod.spec.imagePullSecrets`. For more info follow the tutorial in Kubernetes docs on
**[Pull an Image from a Private Registry](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/)**.

But this did not help me in pulling image from the private registry, I was getting error as
follows:

```bash
$ kubectl get events -w
LASTSEEN                        FIRSTSEEN                       COUNT     NAME          KIND      SUBOBJECT                                TYPE      REASON                  SOURCE           MESSAGE
...
2017-10-06 18:46:11 +0530 IST   2017-10-06 18:40:17 +0530 IST   30        private-reg   Pod                 Warning   FailedSync   kubelet, minikube   Error syncing pod
2017-10-06 18:46:23 +0530 IST   2017-10-06 18:40:17 +0530 IST   31        private-reg   Pod                 Warning   FailedSync   kubelet, minikube   Error syncing pod
2017-10-06 18:46:23 +0530 IST   2017-10-06 18:40:18 +0530 IST   24        private-reg   Pod       spec.containers{private-reg-container}   Normal    BackOff   kubelet, minikube   Back-off pulling image "my-cool-registry.com/surajd-images/busybox:1.26.2"
...
```

Here `private-reg` is the pod name and `my-cool-registry.com/surajd-images/busybox:1.26.2`
is the image name.


The registry uses an identity certificate that is issued by company's internal root CA.
Your minikube VM needs to trust this root CA in order to work properly with the internal
registry. This is where I realized that I had to download the CA cert.

So download the cert and dump it inside the VM, running following command:

```bash
$ certificatefile=<your-ca-crt-file>
$ registryserver=<your-registry-server>

$ cat $certificatefile | minikube ssh "sudo mkdir -p /etc/docker/certs.d/$registryserver && sudo tee /etc/docker/certs.d/$registryserver/ca.crt"
^C
```

**Note**: You will have to press `Ctrl + C`, it should have done writing!

Now you are fully ready to pull the image from this private registry. Happy Hacking!
