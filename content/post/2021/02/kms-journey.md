---
author: "Suraj Deshmukh"
date: "2021-02-23T09:07:07+05:30"
title: "My Knowledge Management Journey"
description: "The story of various tools I have used over last five years."
draft: false
categories: ["non-tech", "KMS", "productivity", "notion"]
tags: ["non-tech", "KMS", "productivity", "notion"]
images:
- src: "/post/2021/02/kms-journey/knowledge.jpg"
  alt: "Knowledge"
---

Photo by [Patrick Tomasso](https://unsplash.com/@impatrickt?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText) on [Unsplash](https://unsplash.com/s/photos/learning?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText).

---

If you are reading this, you are definitely a [Knowledge Worker](https://en.wikipedia.org/wiki/Knowledge_worker). As Knowledge Workers, we rely a lot on the information we know or have access to for our day to day work. Occasionally, we will do the same thing twice, face the situation more than once, want to read that reference or try to understand the insights mentioned in that one particular blog. How do you keep track of such information? How do you find such information again after you have researched it once?! You need a [knowledge management system](https://en.wikipedia.org/wiki/Knowledge_management) that aids you in revisiting such information.

This blog is about my ["Knowledge Management"](https://en.wikipedia.org/wiki/Knowledge_management) journey. The various approaches I have applied over the years, how one became cumbersome over others, and the benefit of subsequent methods over the previous one. If you wanna skip the boring history and get to the solution, then you can just jump to that last two sections. But I think you would appreciate the importance of the last approach only if you know why it is better than others.

## Googling is not the Best Strategy!

If you find yourself googling, again and again, it is a clear sign you want that information quicker in terms of accessibility. Now it depends on the nature of the data. It could command you want to run again, or it could be some term in a specific blog you want to look up for your writing, etc.

## Tweeting it out

In my early days on Twitter, I was only a [leecher](https://en.wikipedia.org/wiki/Leecher_(computing)). Once I struggled with the information storage problem, Twitter turned out to be the best platform to change my leecher hat for a seeder. I decided to tweet any new information I learnt with a tweet. The tweet format used to be something like `Problem Statement: <solution link>`.

{{< tweet 1332302641083269126 >}}

Or if it is a command-line thing, then the structure would be `Problem Statement: <solution commands in monospace> Source link: <link>`.

{{< tweet 1159026822568222721 >}}

If I needed anything from my past tweets, I could simply go to my ["Profile"](https://twitter.com/surajd_) and search for the problem statement. Once the tweets grew on my "Profile", searching went out of hand. Also, the search feature of Twitter is cumbersome to use.

## The Problem of searching tweets

To overcome the search-on-your-Profile problem, I wondered what if I can use Twitter API to download all the tweets from my account and store them in a plain text format to grep it later? To materialise that idea, I wrote [this script (tweetbase)](https://github.com/surajssd/tweetbase/blob/master/tweetbase.go) that would download all the tweets and dump them into a file. The only downside was that I had to run it periodically so that the local file is up to date with the Twitter profile. This has served its purpose to date.

```bash
$ ./run > plain-text-tweets.txt
2021/02/22 10:45:01 All clients ready
2021/02/22 10:45:02 Credentials verified
2021/02/22 10:45:03 Got max id: 1363704708418871301
2021/02/22 10:45:03 Tweets download started
2021/02/22 10:45:13 Tweets download complete
2021/02/22 10:45:13 Tweets dumped to ./alltweets.json
```

```bash
$ grep -i hostpath -A 1 plain-text-tweets.txt
5683:Correction: Whitelisting `allowedHostPath` doesn't help. Only way to get around it is to control permissions on PV… https://t.co/CETzBGf2MQ
5684-URL: https://twitter.com/surajd_/status/1160967381100814342
```

Now I could just open the above link pointing to my tweet.

Sometimes I couldn't remember what "Problem Statement" I had written with the tweet; then, I would be just guessing various terms to search; hence a lot of time would be wasted. Also, Twitter API trims the tweet content, so even if you had typed detailed information, it might not be searchable in the plain text file. You can see that the text is redacted with an ellipsis (`...`).

## Write a script to automate

There are specific commands that you need again-and-again. I would automate that by putting them into a single script.

For, e.g. certain websites disable pasting text into text boxes, and I found a solution to enable pasting. When I discovered it first, I tweeted about it.

{{< tweet 1339602696999845890 >}}

I found myself visiting such websites multiple times. Thus, to copy the solution, I would see the Twitter profile page (until the page was searchable using `Ctrl + F`). Once the tweet on the profile got buried, I started digging (grepping) into the [plain-text-tweets](https://github.com/surajssd/tweetbase/blob/master/plain-text-tweets.txt) file and then jumping to the tweet.

```bash
$ grep -i paste -A 1 plain-text-tweets.txt
470:Copy paste 👇
471-
--
773:var allowPaste = function(e){
774-  e.stopImmediatePropagation();
--
777:document.addEventListener('paste', allowPaste, true);
778-URL: https://twitter.com/surajd_/status/1339602792143458304
```

When this happened more than a couple of times, I decided to script this thing and make this affair faster. The script can be found [here](https://github.com/surajssd/dotfiles/blob/master/local-bin/make-chrome-copy-pastable.sh). Now I just run the script, and the contents are copied to the clipboard to be executed into the chrome tab.

```bash
$ make-chrome-copy-pastable.sh
The code has been copied into the clip board.
Now goto chrome and press Ctrl + Shift + I and paste into the console window.
```

I have explained [in this blog](https://suraj.io/post/framework-for-scripts-and-binaries/) my scripts framework. I have used similar approaches to update the tools I need at their cutting edge. This way, I don't have to search for how to update them every time. I just run the script.

## Your own blog should be easy to find

I started writing blogs where tweets did not serve the purpose. My blogs' nature was problem-oriented (the problems that I encountered and the solution that worked for me in my environment).
With blogs, I took an [NIH](https://en.wikipedia.org/wiki/Not_invented_here) approach (even if there were blogs already written about that topic, I thought I might write it in my words). It served two purposes; they made it easier to search for information for which I had a readymade solution, and the process of writing made my understanding clear. When you write something to explain to others, you must understand all the nitty-gritty details to explain the topic to others in easy to understand language. Since the blogs were created for public consumption, I ensured that I did not make assumptions or tried to make it generic and think from various perspectives.

With that being said, there's still a limit on how much one person can process and distil into writing. My reading volume was many folds greater than the content I was writing. To store information reliably, I needed something that can capture the entire web page and have a search facility, so if I just entered a term, it would fetch all the pages with that term. I gave serious thought to creating a scraper using Python's [Scrapy framework](https://scrapy.org/) but then never got time to do it by myself.

## Save to read later

For the blogs or articles I read, I would save them into [Pocket](https://getpocket.com/) and still do. It is a great tool to keep anything with a web link instead of using just bookmarks. Pocket downloads the webpages by rendering them into a screen-adjustable format. Pocket solved what I was looking for, something that would download the web page's contents to search later. Pocket's search functionality was not so good, and sometimes it rendered pages poorly or only halfway through.

Pocket became my dumping ground for anything, and everything I would wanna read later. It was an endless [~~list~~](https://en.wikipedia.org/wiki/List_(abstract_data_type)) [stack](https://en.wikipedia.org/wiki/Stack_(abstract_data_type)) of blogs, articles, videos and podcasts. The common problem of all the hoarding methodologies (caused by [collector's fallacy](https://zettelkasten.de/posts/collectors-fallacy/)) that I was employing (Twitter, tweetbase and Pocket) was that I was only hoarding information. Never gave a thought to how do I want my future self to find that information. Apart from writing blogs, the other methods didn't make it easier to find information.

## Moving on from hoarding to ease-of-finding

Enter the [Notion](https://notion.so). The solution to every problem is not a Notion page, as shown in this image, but a [Notion database](https://www.notion.so/Intro-to-databases-fd8cd2d212f74c50954c11086d85997e), yes.

![Notion Page Meme](/post/2021/02/kms-journey/notion.jpeg "Notion Page Meme")

The [Notion database](https://www.notion.so/Intro-to-databases-fd8cd2d212f74c50954c11086d85997e) feature is very flexible. Each row is a page, unlike spreadsheets. The page's recursive nature makes Notion databases powerful, within page or database within a page, plus the ability to refer one column of one database into another database.

![Notion Media DB](/post/2021/02/kms-journey/media.png "Notion Media DB")

My Notion system is built similar to what [August Bradley](https://twitter.com/augustbradley) has recommended ([Media](https://www.youtube.com/watch?v=KFQ9qc3p_M8) and [Notes](https://www.youtube.com/watch?v=cbPPelWopis)). I have two Notion databases; one stores "Media" (blogs, videos, podcasts, books), and the other one is called "Notes", and both of these databases are linked.

The Media database has columns that allow me to store metadata like the type of content, category of content, how likely you think it will be relevant, etc. These columns can later be used to filter and create dashboards. Like if I want to view just the media of type articles and in the technology field, I can make a dashboard named "Read - Technology" and have a filtered view of a database. To import content into the Media database, I use the [Notion web clipper](https://www.notion.so/web-clipper). It captures all the content in that webpage and saves it as a Notion page in a database. Once that webpage is copied in Notion, now you can decide what you want to highlight or bold or italic, etc.

![Notion Notes DB](/post/2021/02/kms-journey/notes.png "Notion Notes DB")

While reading, if I have insights, I write those insights and original thoughts into the Notes database. Since these insights were drawn while reading an article, I refer to the Media database field in the Notes database to link them.

This approach is doing upfront work so that you help your future self. Pocket does not provide so much flexibility as Notion does, and there is no way to store your thoughts in Pocket, Pocket limits on how much you can achieve with the stored content, etc.

## Finally

I am using Notion to store something I want to find later. There I can take notes and link the notes to the media source it came from. The Notion has a quick general search function that searches through all the pages. Your brain is the ultimate search engine. Writing notes in your own words helps you form a mental model by connecting various neural pathways. But for anything else, Notion web clipper with Notion databases is a saviour.
