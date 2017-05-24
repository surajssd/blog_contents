+++
author = "Suraj Deshmukh"
title = "Bangalore Kubernetes Meetup May 2017"
date = "2017-05-24T02:21:49+05:30"
description = "Kubernetes and OpenShift 101 hands-on workshop"
categories = ["event report"]
tags = ["kubernetes", "meetup"]

+++

*"One does not simply deploy containers to production"*

![One does not simply deploy containers to production](/images/blr-k8s-meetup-may-2017/mordor_meme.jpg "One does not simply deploy containers to production")

With the rising craze around the container community in Bangalore and relative lack in awareness
around different container technologies like [Kubernetes](http://kubernetesbyexample.com/) and [OpenShift](https://developers.openshift.com/),
an effort was made in imparting knowledge in this direction.

So, this time around newbies were targeted for the Kubernetes Meetup.

With the above objective, it was decided to have a [Kubernetes 101 workshop](https://www.meetup.com/kubernetes-openshift-India-Meetup/events/239381714/)
 at Red Hat Bangalore office on May 21, 2017 to familiarize people with concepts of Kubernetes and OpenShift and their
 usage and relevance as container orchestration tools for managing application deployments.

The schedule for the Meetup was as follows:

- Kubernetes 101 - Knowing the terms in Kubernetes
- Kubernetes 101 - Hands-on workshop
- OpenShift 101 - What OpenShift adds to Kubernetes?
- OpenShift 101 - Hands-on workshop

As per the schedule, we opened the floor with a talk by [Hemani Katyal](https://www.linkedin.com/in/hemani-katyal-57900081)
 on Kubernetes Basics([slides](https://docs.google.com/presentation/d/1pUg6eOfIfznSS-2m1-7EEXbyHyH9NPgCRZw6WcX6FG4/edit?usp=sharing)),
 wherein she explained the need for Kubernetes, what it is, it's architecture, why Kubernetes would be better container
 orchestrator and the constructs of Kubernetes like pods, volumes, labels, replications controllers, services, etc.

![Hemani Katyal](/images/blr-k8s-meetup-may-2017/hemani.jpg "Hemani Katyal explaining Kubernetes")

It was good to see people interested in concepts of service and the way it load balances traffic, how the labels
 construct is helpful in bringing in flexibility with deployments, why Kubernetes is better than other container
 orchestrators.

Following up with the excitement, [Suraj Deshmukh](https://twitter.com/surajd_), [Abhishek Singh](https://twitter.com/procrypt0),
 [Zeeshan Ahmed](https://twitter.com/zee_10000) and [Shubham Minglani](https://twitter.com/ContainsCafeine) happily
 volunteered to conduct the hands-on workshop. The workshop exercises were taken from [Kubernetes section](https://www.katacoda.com/courses/kubernetes)
 of [katacoda.com](https://www.katacoda.com/).

![Zeeshan Ahmed](/images/blr-k8s-meetup-may-2017/mzee.jpg "Zeeshan Ahmed explaining Kubernetes Secrets and ConfigMaps")

It was pleasure to have an excited and responsive audience. Questions like kube-adm functionality on CentOS,
 installing Kubernetes in an isolated environment without internet, how ingress works and the likes of the same were
 asked during the hands-on session.

![Shubham Minglani](/images/blr-k8s-meetup-may-2017/shubham.jpg "Shubham Minglani explaining Kubernetes HealthChecks")

Post a quick coffee break, [Abhishek Singh](https://twitter.com/procrypt0) briefed the audience about OpenShift basics([slides](https://docs.google.com/presentation/d/1e9dEuNfoFI0kMbtQmPUIgw85zS7s-cvupWB5ogYxdpc/edit?usp=sharing)),
 wherein he explained what OpenShift is and how it is an addon on top of Kubernetes. He touched upon topics like user
 management, various build features of OpenShift, container image handling in OpenShift, the way deployment fits in with
 build part, security, running OpenShift locally using [Minishift](https://github.com/minishift/minishift/), to name a few.

![Abhishek Singh](/images/blr-k8s-meetup-may-2017/abhi.jpg "Abhishek Singh explaining OpenShift")

Satiating the hunger not just for knowledge but food as well, we broke for lunch.

Post which we continued with OpenShift hand-on exercises, which were again from [OpenShift section](https://learn.openshift.com/)
 of [katacoda.com](katacoda.com). [Zeeshan Ahmed](https://twitter.com/zee_10000), [Suraj Narwade](https://twitter.com/red_suraj)
 and [Abhishek Singh](https://twitter.com/procrypt0) helped with the workshop exercises. There seemed to be lot of
 interest around topics like the [source to image](https://docs.openshift.com/enterprise/3.0/architecture/core_concepts/builds_and_image_streams.html#source-build)
 feature of OpenShift, if [OpenShift’s router](https://docs.openshift.com/enterprise/3.2/dev_guide/routes.html) allowed
 UDP traffic, the difference between ingress and routes.

Red Hat’s latest announcement regarding the [integration of AWS services with OpenShift](https://blog.openshift.com/aws-and-red-hat-digging-a-little-deeper/)
 also generated some curiosity among the audience.

![Folks listening](/images/blr-k8s-meetup-may-2017/people.jpg "Folks listening")

The meetup concluded asking for [feedback](https://goo.gl/forms/ILSI0Xb3OKuKMKht2) and distributing some swag. In
 feedback we received, people wanted to see some real world examples, the kind of applications that run on these
 platforms, and much more which are advanced topics and we would love to take up in normal meetup as opposed to a 101.

I would like to conclude here by thanking all speakers, volunteers for spreading knowledge, [katacoda.com](katacoda.com)
 for awesome workshop material and audience for listening patiently and trying out things and making this meetup
 successful. And last but not the least, I would like to express my deepest gratitude to Red Hat for sponsoring the event
 and providing us with the venue and [Hemani Katyal](https://www.linkedin.com/in/hemani-katyal-57900081)
 for making this post an awesome read.


## Links

- Kubernetes DIY hands-on exercises [https://www.katacoda.com/courses/kubernetes](https://www.katacoda.com/courses/kubernetes)
- OpenShift DIY hands-on exercises [https://learn.openshift.com/](https://learn.openshift.com/)
