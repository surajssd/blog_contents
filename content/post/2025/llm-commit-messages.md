---
author: "Suraj Deshmukh"
date: "2025-07-17T15:21:07-08:00"
title: "Using LLMs to write meaningful commit messages from CLI"
description: "Learn how to use the llm CLI tool with GitHub Copilot models to generate meaningful commit messages directly from your terminal."
draft: false
categories: ["ai", "llm", "copilot", "cmd-line", "bash", "git", "linux", "productivity", "programming", "desktop"]
tags: ["ai", "desktop", "development", "git", "github", "linux", "llm", "productivity", "programming", "copilot", "cli"]
cover:
  image: "/post/2025/images/llm-gh-copilot.png"
  alt: "LLM CLI tool using GitHub Copilot Models"
---

Let's face it, writing commit messages is tedious work. I've been using LLMs to write my commit messages for a while now. But until now, I used to copy the diffs manually and paste it into some chat window and ask the LLM to write a commit message.

I've been trying various CLI tools viz. [OpenAI's Codex CLI](https://github.com/openai/codex), [Google's Gemini CLI](https://github.com/google-gemini/gemini-cli), etc. But codex [lacks piping support](https://github.com/openai/codex/issues/1123) and Gemini CLI cannot be used with internal codebases! I can use GitHub Copilot extension in VS Code with internal codebases, but I wanted a CLI tool that I can use in my terminal. GitHub Copilot is [now free](https://github.blog/news-insights/product-news/github-copilot-in-vscode-free/) for all GitHub users, so this is useful for everyone.

I've been aware of the CLI tool [`llm`](https://llm.datasette.io) for a while now. The project defines itself as follows:

> A CLI tool and Python library for interacting with OpenAI, Anthropic’s Claude, Google’s Gemini, Meta’s Llama and dozens of other Large Language Models, both via remote APIs and with models that can be installed and run on your own machine.

This `llm` tool has a plugin mechanism, where others can write extensions to use different LLMs. Here is an extensive list of all the [supported plugins](https://llm.datasette.io/en/stable/plugins/index.html#plugins).

Coming back to my use case, I came across this plugin called [`llm-github-copilot`](https://github.com/jmdaly/llm-github-copilot), which allows you to use GitHub Copilot's LLMs directly from the command line. This is exactly what I was looking for! Rest of this post is a quick guide on how to use this tool to write meaningful commit messages using LLMs.

## Installation

Install `llm` CLI either using `uv` or other tools of your choice. I prefer `uv` as it is cleaner and faster. Here are [more ways](https://llm.datasette.io/en/stable/setup.html#installation) to install the `llm` CLI.

```bash
uv tool install llm
```

Install the `llm` CLI's GitHub Copilot extension like this:

```bash
llm install llm-github-copilot
```

## One-Time Configuration

Login to your GitHub account to enable the `llm-github-copilot` extension:

```bash
llm github_copilot auth login
```

Find the supported model by running the following command:

```bash
llm github_copilot models
```

Set a default model to use:

```bash
llm models default github_copilot/claude-sonnet-4
```

## Usage

Generate commit messages:

```bash
git diff master | llm "Look at this diff and write a detailed commit message"
```

You can change the `git diff` command or the instructions as per your requirements. Here is another example to generate commit messages for staged changes:

```bash
git diff --cached | llm "Write a commit message for these staged changes"
```

### Request Entity Too Large

Sometimes the `llm` CLI can return an error like this:

```bash
Error: Request Entity Too Large
```

One way to avoid this is to reduce the amount of content you are passing to the `llm` CLI.

### Using the non-default model

If you want to use a different model than the default one, you can specify it like this:

```bash
llm -m github_copilot/gpt-4o ...
```

## Conclusion

Using LLMs to write meaningful commit messages can significantly improve your productivity and the quality of your codebase. The `llm` CLI tool with the GitHub Copilot extension makes it easy to generate these messages directly from your terminal, without needing to switch contexts or copy-paste between applications.

Although LLMs generate good commit messages, they may not always be exactly what you want. You should always review the generated messages, make necessary edits, and ensure they follow your project's commit message conventions.
