# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Hugo static site generator repository for a personal blog (suraj.io). The blog uses the PaperMod theme and is deployed to GitHub Pages at surajssd.github.io.

## Commands

### Development and Build

```bash
# Build the site (generates output to ./public/)
hugo

# Serve locally with live reload (typically at http://localhost:1313)
hugo serve

# Serve with drafts enabled
hugo serve -D
```

### Publishing

```bash
# Build and publish to GitHub Pages
# Usage: ./hack/build-and-publish.sh "your commit message"
./hack/build-and-publish.sh "commit message"
```

This script (`hack/build-and-publish.sh`):
1. Fast-forward pulls (`--ff-only`) the source repo so it never publishes a stale branch, then builds with `hugo`
2. Fast-forward pulls the website repo, then copies `public/.` into it
3. Commits (signed `-S`, signed-off `-s`) and pushes **master** in both repos via a normal `git push`, skipping any repo whose tree is unchanged

Key behaviors to be aware of:
- The copy uses `cp -r public/.` and **never deletes** files in the website repo. This is intentional — the website repo holds assets Hugo never regenerates (`CNAME`, `themes/`, `keybase.txt`), and an `rsync --delete`-style sync would wipe them.
- The website repo path defaults to the sibling `../surajssd.github.io` and can be overridden with the `WEB_REPO` environment variable.
- `--ff-only` makes the script fail loudly if local and remote have diverged, rather than creating a merge commit.

## Architecture

### Content Structure

- **`content/post/`**: Blog posts. Older posts live directly in `content/post/`; newer posts are organized by year subdirectories (`2021/`, `2024/`, `2025/`, `2026/`)
- **`content/post/<year>/images/`** and **`content/images/<post-slug>/`**: Post images (two conventions coexist — newer year-based dirs and older per-slug dirs)
- **`content/about.md`, `archives.md`, `search.md`**: Standalone pages backing the menu entries in `config.yaml`
- **`draft/`**: Standalone draft files kept outside `content/` (Hugo does not render these). Note: in-content drafts instead use `draft: true` in frontmatter and require `hugo serve -D` to preview. `buildDrafts: false` in `config.yaml` keeps them out of production builds.

### Configuration

- **`config.yaml`**: Main Hugo configuration
  - Site metadata and base URL
  - PaperMod theme configuration via Hugo modules
  - Menu structure (Blog, About, Archives, Search, Tags, Categories, Series)
  - Social media links
  - Disqus comments integration
  - Google Analytics setup
  - Fuse.js search configuration

### Theme

The site uses the PaperMod theme, imported as a Hugo module:
- **Module**: `github.com/adityatelange/hugo-PaperMod` (pinned in `go.mod` as an `// indirect` dep; Renovate is configured to update it despite being indirect — see `renovate.json`)
- **Dependencies**: Managed via `go.mod` and `go.sum`
- Features: Dark/light mode toggle, search, reading time, code copy buttons, breadcrumbs, TOC

### Custom Layout Overrides

The theme is customized by shadowing files in the local `layouts/` directory (Hugo merges these over the module's layouts):
- **`layouts/partials/comments.html`**: Disqus integration. Disables comments on `localhost`/`127.0.0.1` so previews don't load Disqus; reads optional `disqus_identifier`/`disqus_title`/`disqus_url` from post frontmatter.
- **`layouts/shortcodes/youtubestartend.html`**: Embeds a YouTube video with start/end timestamps. Usage in content: `{{< youtubestartend VIDEO_ID START_SECONDS END_SECONDS >}}`.

### Post Frontmatter

Blog posts follow this structure:
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

### Output and Publishing

- **`public/`**: Generated static site output (created by `hugo`). Not committed in this repo — it is copied into the separate `../surajssd.github.io/` repository by the publish script

### Git Workflow

- This repo holds the **source** (content, config, layout overrides); the **generated HTML** is deployed to a separate repo (`surajssd.github.io`) which GitHub Pages serves
- Both repos are committed and pushed together by `hack/build-and-publish.sh` (normal push to `master`, not a force-push)
- The custom domain is `suraj.io` (set via `CNAME`, which lives in the website repo and is preserved by the non-deleting copy)
