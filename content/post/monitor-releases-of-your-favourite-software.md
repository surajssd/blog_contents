+++
author = "Suraj Deshmukh"
title = "Monitor releases of your favourite software"
description = "Be on top of the releases of the software you rely upon!"
date = "2021-01-17T12:28:51+05:30"
categories = ["programming", "productivity"]
tags = ["programming", "productivity"]
+++


There are various ways to know about the release of your favourite new software, follow the mailing list, check the Github release page periodically, follow the project's Twitter handle, etc. But do you know there is even more reliable way to track the releases of your favourite software released on Github.

## Github Releases and RSS feeds

For every repository on Github, if the project is posting their releases, you can follow the RSS feed of that project's release. The RSS feed link for any project's release is:

```bash
https://github.com/projectrepo/projectname/releases.atom
```

For example, you can follow the [Istio](https://istio.io/) project release RSS feed [here](https://github.com/istio/istio/releases.atom).

## RSS Reader App

You can find many RSS reader apps out there, read this [Zapier article](https://zapier.com/blog/best-rss-feed-reader-apps/) about the other options. In these apps add the `*.atom` links to follow the feed.

Here I will show how to track releases with Slack.

### Step 1: Go to Apps section in Slack sidebar.

![Go to the Apps section](/images/monitor-releases-of-your-favourite-software/1.png "Go to the Apps section")

### Step 2: Search for RSS.

![Search for RSS](/images/monitor-releases-of-your-favourite-software/2.png "Search for RSS")

Once you click the "Add" it will open up browser.

### Step 3: Add to Slack.

![Add to Slack](/images/monitor-releases-of-your-favourite-software/3.png "Add to Slack")
![Add RSS intergration](/images/monitor-releases-of-your-favourite-software/4.png "Add RSS intergration")


### Step 4: Add the `*.atom` URLs.

In the "Add a Feed" section start adding the RSS feed links of the projects you want to monitor:

![Subscribe to this feed](/images/monitor-releases-of-your-favourite-software/5.png "Subscribe to this feed")


### Step 5: Check the subscribed feeds.

![Check your subscription](/images/monitor-releases-of-your-favourite-software/6.png "Check your subscription")


### Step 6: Add from Slack comments section.

You can also start watching a feed of a project from the Slack comment section. Type the following command in a channel you want to those release notifications:

```bash
/feed subscribe https://github.com/kubernetes/kubernetes/release.atom
```

You will see a comment like this:

![Subscription confirmation](/images/monitor-releases-of-your-favourite-software/7.png "Subscription confirmation")

## Closing remarks

I hope you don't miss out on the latest release of your favourite application.
