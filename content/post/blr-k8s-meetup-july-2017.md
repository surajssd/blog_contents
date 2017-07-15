+++
author = "Suraj Deshmukh"
description = "Kubernetes Meetup presentation and talks"
date = "2017-07-13T22:46:40+05:30"
title = "Bangalore Kubernetes Meetup July 2017"
categories = ["event_report"]
tags = ["kubernetes", "meetup", "openshift"]

+++


This [edition of meetup](https://www.meetup.com/kubernetes-openshift-India-Meetup/events/240859625/)
was held at Nexus Ventures by folks at [OpenEBS](https://twitter.com/openebs)
on July 8th 2017, which started on a lovely Saturday morning.

[Kiran Mova](https://twitter.com/kiranmova) set the floor rolling with his talk
on *Hyperconverged version of OpenEBS with Kubernetes*. Where he talked about
containerized storage vs traditional storage, instead of building clustering
into [OpenEBS](https://github.com/openebs/openebs) how they are leveraging
Kubernetes's capabilities to do clustering.

![openEBS demo](/images/blr-k8s-meetup-july-2017/kiran.JPG "openEBS demo")

He also explained difference between various storage providers viz. Portworx,
StorageOS, Rook, GlusterFS, OpenEBS, etc.

<center>
<iframe width="595" height="485" src="https://www.youtube.com/embed/LRdcah-fs0g"
frameborder="0" style="border:1px solid #CCC; border-width:1px;
margin-bottom:5px; max-width: 100%;" allowfullscreen></iframe>
<div style="margin-bottom:5px"> <strong>
<a href="//youtu.be/LRdcah-fs0g"
title="Hyperconverged version of OpenEBS with Kubernetes"
target="_blank">Hyperconverged version of OpenEBS with Kubernetes</a>
</strong> by <strong><a target="_blank"
href="https://twitter.com/kiranmova">Kiran Mova</a></strong>
</div>
</center>


Then was talk by [Kamesh Sampath](https://twitter.com/kamesh_sampath) on
[Istio](https://github.com/istio/istio) named *A sail in the cloud*.
Specifically tracing, monitoring, service discovery with Istio.

<center><iframe src="//www.slideshare.net/slideshow/embed_code/key/fKzj4nGkTEsXnH"
width="595" height="485" frameborder="0" marginwidth="0" marginheight="0"
scrolling="no" style="border:1px solid #CCC; border-width:1px;
margin-bottom:5px; max-width: 100%;" allowfullscreen> </iframe>
<div style="margin-bottom:5px"> <strong>
<a href="//www.slideshare.net/kameshsampath/a-sail-in-the-cloud"
title="A sail in the cloud" target="_blank">A sail in the cloud</a>
</strong> from <strong><a target="_blank"
href="https://www.slideshare.net/kameshsampath">Kamesh Sampath</a></strong>
</div></center>

He explained the Istio Service Mesh architecture and all components it has.
How side-car pattern is being used to deploy Istio with the existing apps in
Kubernetes.

![side-car config](/images/blr-k8s-meetup-july-2017/kamesh.JPG "side-car configuration")

He talked and demoed about Canary deployment, tracing and Circuit breaking with
Istio. Watch the video recording of talk by Kamesh to learn in detail. Here is
his [demo content](https://github.com/workspace7/sail-into-cloud).

<center>
<iframe width="595" height="485" src="https://www.youtube.com/embed/LRdcah-fs0g?start=2020"
frameborder="0" style="border:1px solid #CCC; border-width:1px;
margin-bottom:5px; max-width: 100%;" allowfullscreen></iframe>
<div style="margin-bottom:5px"> <strong>
<a href="//youtu.be/LRdcah-fs0g?t=33m40s"
title="A sail in the cloud"
target="_blank">A sail in the cloud</a>
</strong> by <strong><a target="_blank"
href="https://twitter.com/kamesh_sampath">Kamesh Sampath</a></strong>
</div>
</center>


After a snacks break, there was a talk by [Zeeshan Ahmed](https://twitter.com/zee_10000)
about *Dance of container image building*. The main highlight of this highly
interactive session was on best practices to be followed for building container
images.

![buildah in action](/images/blr-k8s-meetup-july-2017/zeeshan.JPG "buildah in action")

Where he explained why it is not a good idea to bake configs and
secrets into container image and how one can use use Kubernetes secrets and
configMaps to get this configs and secrets in the container on the fly, he
then demoed the tool buildah where you don't need a docker daemon to build
the container image.

<center>
<iframe width="595" height="485" src="https://www.youtube.com/embed/LRdcah-fs0g?start=5961"
frameborder="0" style="border:1px solid #CCC; border-width:1px;
margin-bottom:5px; max-width: 100%;" allowfullscreen></iframe>
<div style="margin-bottom:5px"> <strong>
<a href="//youtu.be/LRdcah-fs0g?t=1h39m21s"
title="Dance of container image building"
target="_blank">Dance of container image building</a>
</strong> by <strong><a target="_blank"
href="https://twitter.com/zee_10000">Zeeshan Ahmed</a></strong>
</div>
</center>


Followed by Zeeshan was talk by [Saravanakumar](https://uyirpodiru.blogspot.in/)
where he talked about *Source to Image in OpenShift*, where he explained what
is s2i, how you can use s2i with the running OpenShift cluster by directly
providing github url of a project and see it deployed on OpenShift.

![s2i demo](/images/blr-k8s-meetup-july-2017/saravanakumar.JPG "s2i demo")

Then he demonstrated how you can build your own builder image for OpenShift s2i.
[Link to slides](http://goo.gl/xYJnuG).

<center>
<iframe width="595" height="485" src="https://www.youtube.com/embed/LRdcah-fs0g?start=9048"
frameborder="0" style="border:1px solid #CCC; border-width:1px;
margin-bottom:5px; max-width: 100%;" allowfullscreen></iframe>
<div style="margin-bottom:5px"> <strong>
<a href="//youtu.be/LRdcah-fs0g?t=2h30m48s"
title="Source to Image in OpenShift"
target="_blank">Source to Image in OpenShift</a>
</strong> by <strong><a target="_blank"
href="https://uyirpodiru.blogspot.in/">Saravanakumar</a></strong>
</div>
</center>


The meetup ended with announcements of [Kubernetes Birthday meetup](https://www.meetup.com/Bangalore-Mesos-cncf-User-Group/events/240781879/)
and awesome burgers from Truffles sponsored by OpenEBS. Thanks all speakers,
attendees and sponsors for making this meetup a success. Thanks to OpenEBS
for being a generous sponsors, and specifically [Kiran](https://twitter.com/kiranmova)
and [Nisanta](https://twitter.com/_nisanta_) for organizing logistics and
helping on the day of meetup. Thanks to [Hemani](https://www.linkedin.com/in/hemani-katyal-57900081)
and [Zeeshan](https://twitter.com/zee_10000) for editing this post.
