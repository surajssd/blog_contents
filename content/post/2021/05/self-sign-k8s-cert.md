---
author: "Suraj Deshmukh"
date: "2021-05-21T15:33:07+05:30"
title: "How to generate a self-signed TLS certificate for Kubernetes Admission Webhook Servers?"
description: "A simple binary to generate TLS x509 certificates."
draft: false
categories: ["kubernetes", "security"]
tags: ["kubernetes", "security"]
images:
- src: "/post/2021/05/self-sign-k8s-cert/cert.png"
  alt: "cert"
---

> **UPDATE:** There is a way to generate these certificates automatically. To find out how, [read this post](https://suraj.io/post/2021/06/automatic-cert-gen/).

If you are writing a webhook server for [Kubernetes Admission Controllers](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#what-are-they) like [ValidatingAdmissionWebhooks](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#validatingadmissionwebhook) or [MutatingAdmissionWebhooks](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#mutatingadmissionwebhook), you must expose it over HTTPS. To run these servers on HTTPS, you need TLS certificates. There are solutions available which you can use to solve this problem, first and foremost that comes to my mind is [cert-manager](https://cert-manager.io/docs/). It is a great project and automates this problem. But it is an added dependency that you might have to keep running in your cluster.

## Self Signed Cert Generation

To avoid the added dependency of cert-manager and similar solutions, I chose to create a small tool to generate a certificate that you can use with your webhook server. The code for the tool is inspired by the Kubernetes test infra code. It takes in the service name and the namespace name and generates a private key and certificate in a temporary directory.

Install the tool by following [these instructions](https://github.com/surajssd/self-signed-cert#install). And once installed in your `PATH`, you can generate certificates by simply running the following command:

```bash
$ self-signed-cert --namespace=webhook --service-name=server
/tmp/self-signed-certificate311397173
```

And these three files generated in that directory:

```bash
$ ls /tmp/self-signed-certificate311397173
ca.crt  server.crt  server.key
```

## Loading certs into the Helm chart

Now your webhook server helm chart can load those certs from the temporary directory. Helm has an excellent provision to do so. For example, you can simply add them to your values file with a flag like `--set-file`.

See the following flow of installation:

```bash
# Generate certs and store the path to certs in a variable.
certs=$(self-signed-cert --namespace validate-secrets --service-name validate-secrets)

# Now load those certs into the helm chart.
helm install mywebhookserver \
    --set-file key=$certs/server.key \
    --set-file cert=$certs/server.crt .
```

Note that the above certificates are not `base64` encoded, so ensure that you encode them in your helm templates. Add a snippet that looks like the following:

```yaml
key.pem: "{{ .Values.key | b64enc }}"
```

## Loading certs for a Golang web server

Here I am showing how to load those certificates for serving into a webserver written in golang. For other programming languages, you can follow the required steps to expose a server with HTTPS support.

![go code](/post/2021/05/self-sign-k8s-cert/gocode.png "go code")

I have removed the error handling parts for simplicity of code, but please add them to your code.

---

Let me know what tools do you use to generate private certificates for the webhook servers.

> **UPDATE:** There is a way to generate these certificates automatically. To find out how, [read this post](https://suraj.io/post/2021/06/automatic-cert-gen/).
