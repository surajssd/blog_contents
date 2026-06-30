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

This script:
1. Runs `hugo` to build the site
2. Copies `public/*` to `../surajssd.github.io/`
3. Commits and force-pushes to master in both repos
4. Commits are signed (-S) and signed-off (-s)

## Architecture

### Content Structure

- **`content/post/`**: Blog posts, organized by year subdirectories (e.g., `2024/`, `2025/`, `2026/`) and some posts directly in the root
- **`content/post/*/images/`**: Images for posts, typically organized in year-specific image directories
- **`draft/`**: Draft posts not yet ready for publication

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
- **Module**: `github.com/adityatelange/hugo-PaperMod`
- **Dependencies**: Managed via `go.mod` and `go.sum`
- Features: Dark/light mode toggle, search, reading time, code copy buttons, breadcrumbs, TOC

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

- **`public/`**: Generated static site output (created by `hugo` command)
- The publish script copies this to the separate `../surajssd.github.io/` repository
- Published site is force-pushed to master

### Git Workflow

- Blog content and source are in this repository
- Generated site output is deployed to a separate repository (`surajssd.github.io`)
- Both repositories are committed and pushed together via the publish script
