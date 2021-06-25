---
author: "Suraj Deshmukh"
date: "2021-06-25T09:00:00+05:30"
title: "How to 'automatically' generate a self-signed TLS certificate for Kubernetes Admission Webhook Servers?"
description: "A simple Helm chart to generate TLS x509 certificates."
draft: false
categories: ["kubernetes", "security"]
tags: ["kubernetes", "security"]
images:
- src: "/post/2021/06/automatic-cert-gen/obama.jpg"
  alt: "Self Signed Certificates"
---

The [previous blog](https://suraj.io/post/2021/05/self-sign-k8s-cert/) talked about generating self-signed certificates using a binary. It was a manual, cumbersome process where you had to generate the certificates using a tool, embed them into a Kubernetes Secret via Helm chart, and then use it. There is a better way of doing it! Which is what this blog will discuss.

We will use a Helm chart, which has a couple of Kubernetes Jobs that generates the self-signed certificate, embed them in a Kubernetes Secret and finally update the `ValidatingWebhookConfiguration` or `MutatingWebhookConfiguration` of your choice. And that’s it. Life is simpler!

Let us look at the detailed usage steps. There are two modes of using it. If you are into the [Helm](https://helm.sh/) eco-system, then we can use it as a sub-chart, AKA dependent chart. And then let us also look at using it via plain simple `kubectl apply` way.

## Helm Sub-chart

Helm allows you to specify a particular chart to be a dependency for your chart. During installation, Helm will install the dependencies first and then install your application chart. When you install a chart as a dependency, it is effortless to do the maintenance. You just have to keep updating the dependent chart version going forward.

Let us start out by adding the dependency in your chart. Include the following snippet in your chart’s `Chart.yaml` file:

```yaml
dependencies:
- name: automatic-webhook-certificates
  version: "0.1.1"
  repository: "https://suraj.io/helm-charts"
```

Now define the configuration for the sub-chart. To do that, include the following configuration in your chart's `values.yaml` file with fields populated as necessary:

```yaml
automatic-webhook-certificates:
  webhook:
    name: <name of the webhook config>
    service: <name of the service serving the webhook pod>
    secret: <secret you wish to have certificates stored>
    failurePolicy: Fail or Ignore
    validating: true or false
    mutating: true or false
  psp: true or false
```

**NOTE**: For detailed information on each field in the above values file, consult [this documentation](https://github.com/surajssd/helm-charts/tree/main/charts/automatic-webhook-certificates).

Once this sub-chart is installed, a Kubernetes Secret will be created by the [kube-webhook-certgen](https://github.com/jet/kube-webhook-certgen) running as a Kubernetes Job. The certs will be stored in a Kubernetes Secret that you mentioned in the values file at `webhook.secret`. The Kubernetes Secret has keys named `ca`, `cert` and `key`.

Before you install your chart, run the following commands:

```bash
helm dependency update
helm install ...
helm upgrade ...
```

## Plain simple Kubernetes configuration

Although this type of configuration consumption does promise using plain simple `kubectl apply`, it needs Helm to download the configuration release. First, create the `values.yaml` file:

```yaml
webhook:
  name: <name of the webhook config>
  service: <name of the service serving the webhook pod>
  secret: <secret you wish to have certificates stored>
  failurePolicy: Fail or Ignore
  validating: true or false
  mutating: true or false
psp: true or false
```

**NOTE**: For detailed information on each field in the above values file, consult [this documentation](https://github.com/surajssd/helm-charts/tree/main/charts/automatic-webhook-certificates).

Now run the following commands to generate the YAML file:

```bash
helm repo add suraj-helm-charts https://suraj.io/helm-charts
helm repo update
helm template \
    --values=values.yaml \
    --namespace=<namespace> \
    automatic-webhook-certificates \
    suraj-helm-charts/automatic-webhook-certificates > auto-cert-gen.yaml
```

The downside with this approach is that you will have to generate this YAML file from time to time as new updates are rolled out.

## Manual vs Automatic

Now let us see what the subtle advantages and disadvantages of Manual and Automatic cert generation methods are. The most obvious one is convenience. But like in most places, this convenience comes with a trade-off. Since [kube-webhook-certgen](https://github.com/jet/kube-webhook-certgen) runs inside the Kubernetes cluster, creating secrets and updating the Webhook configurations. It needs permissions to make these modifications on the Kubernetes cluster.

If you were to run the binary locally, as mentioned in the [previous blog](https://suraj.io/post/2021/05/self-sign-k8s-cert/) none of these elevated permissions would be needed inside the cluster.

## Conclusion

I think security-wise, this is not a huge trade-off. The seemingly elevated permissions are given to the [kube-webhook-certgen](https://github.com/jet/kube-webhook-certgen), which runs as a Kubernetes Job and most of the time, it finishes within few seconds. And it is generally the long-running processes that hone the risk of exposing secrets. So it is wise to save some time by using the automated cert generation approach explained in this blog.
