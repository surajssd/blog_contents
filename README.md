# blog_contents

Source for my personal blog, **[suraj.io](https://suraj.io)** — a [Hugo](https://gohugo.io/) static site built with the [PaperMod](https://github.com/adityatelange/hugo-PaperMod) theme.

This repository holds the source (content, config, layouts). The generated HTML is published to a separate repository, [`surajssd.github.io`](https://github.com/surajssd/surajssd.github.io), which serves the site via GitHub Pages.

## Prerequisites

- [Hugo](https://gohugo.io/installation/) (extended version recommended)
- [Go](https://go.dev/dl/) — the PaperMod theme is pulled in as a [Hugo Module](https://gohugo.io/hugo-modules/), so `go.mod`/`go.sum` manage it

## Local development

```bash
# Serve locally with live reload (http://localhost:1313)
hugo serve

# Include draft posts
hugo serve -D

# Build the static site into ./public/
hugo
```

## Publishing

Building and deploying is handled by a single script:

```bash
./hack/build-and-publish.sh "your commit message"
```

It will:

1. Pull the latest source so it never pushes a stale branch.
2. Build the site with `hugo`.
3. Copy the fresh build into the sibling `surajssd.github.io` repo.
4. Commit (signed + signed-off) and push both repos, skipping any repo with no changes.

The published site repo is expected at `../surajssd.github.io` by default; override with the `WEB_REPO` environment variable.

## Repository layout

```
content/         Blog content
  post/          Posts — older ones in the root, newer organized by year (2024/, 2025/, ...)
  about.md       About page
  archives.md    Archives page
config.yaml      Main Hugo configuration (menus, params, theme, analytics, search)
layouts/         Custom layout overrides (partials, shortcodes)
static/          Static assets (favicons, etc.)
hack/            Helper scripts (build-and-publish.sh)
go.mod / go.sum  Hugo Module dependencies (PaperMod theme)
renovate.json    Renovate config for automated dependency updates
CNAME            Custom domain (suraj.io)
```

## Writing a post

Posts live under `content/post/` (newer ones under a year subdirectory). Each post is a Markdown file with frontmatter:

```yaml
---
author: "Suraj Deshmukh"
date: "YYYY-MM-DDTHH:MM:SS-TZ"
title: "Post Title"
description: "Post description"
draft: false
categories: ["category1", "category2"]
tags: ["tag1", "tag2"]
cover:
  image: "/post/YYYY/images/filename.png"
  alt: "Alt text"
---
```

Post images are typically kept in a per-year `images/` directory and referenced from the frontmatter `cover.image` and post body.
