---
author: "Suraj Deshmukh"
date: "2026-01-31T10:00:00+05:30"
title: "Using Claude Code with GitHub-Hosted Anthropic Models"
description: "Learn how to use Claude Code CLI with GitHub Models by proxying requests through litellm-proxy"
draft: false
categories: ["AI", "Developer Tools"]
tags: ["claude", "github-models", "ai", "litellm", "anthropic"]
cover:
  image: "/post/2026/images/claude-litellm-gh-models.png"
  alt: "Using Claude Code with GitHub Models"
---

## Introduction

[Claude Code](https://claude.ai/code) is an incredible AI-powered coding assistant that runs in your terminal. While it typically connects to Anthropic's API, did you know you can use it with [GitHub Hosted Anthropic Models](https://github.com/marketplace/models) instead? This is particularly useful if you have access to GitHub's AI model.

In this post, I'll show you how to proxy Claude Code requests to GitHub-hosted Anthropic models using [litellm](https://github.com/BerriAI/litellm), an open-source proxy server that translates between different LLM API formats.

## Prerequisites

Before getting started, you'll need:

- Claude Code installed (see [installation instructions](https://code.claude.com/docs/en/quickstart))
- Python 3.11 or higher
- Access to GitHub Models (available through GitHub Copilot)

## How It Works

The setup uses litellm-proxy as a translation layer:

```bash
Claude Code → litellm-proxy (localhost:4000) → GitHub Models API
```

The proxy intercepts Claude API calls and forwards them to GitHub's infrastructure while presenting responses in the format Claude Code expects.

## The Setup Script

I've created a bash script that automates the entire setup process. The script handles three main tasks:

1. **Virtual Environment Management**: Creates a Python 3.11 venv and installs litellm
2. **Claude Configuration**: Configures Claude Code to use the local proxy
3. **LiteLLM Configuration**: Sets up the proxy to forward requests to GitHub Models

You can find the complete script here: [litellm-proxy.sh](https://github.com/surajssd/dotfiles/blob/master/local-bin/litellm-proxy.sh)

### Key Configuration Details

The script modifies `~/.claude/settings.json` to point Claude Code to the local proxy:

```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "sk-",
    "ANTHROPIC_BASE_URL": "http://localhost:4000",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "claude-opus-41",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "claude-sonnet-4.5",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "claude-sonnet-4.5",
    "ANTHROPIC_MODEL": "claude-sonnet-4.5",
    "ANTHROPIC_SMALL_FAST_MODEL": "claude-sonnet-4.5",
    "CLAUDE_CODE_SUBAGENT_MODEL": "claude-sonnet-4.5"
  }
}
```

It also creates a litellm configuration at `~/.config/litellm/config.yaml`:

```yaml
general_settings:
  master_key: sk-
litellm_settings:
  disable_copilot_system_to_assistant: true
  drop_params: true
model_list:
- model_name: '*'
  litellm_params:
    model: github_copilot/*
    extra_headers:
      Editor-Version: vscode/1.372.0
```

The wildcard model matching (`'*'`) ensures all Claude model requests are caught and forwarded to GitHub's backend. The `Editor-Version` header mimics VS Code to satisfy GitHub's API requirements.

## Usage

### Starting the Proxy

First, start the litellm proxy server:

```bash
litellm-proxy.sh start
```

This will:

- Create the Python virtual environment (on first run)
- Install litellm and dependencies
- Generate configuration files
- Start the proxy server on `http://localhost:4000`

You should see output indicating the server is running:

```bash
➜  litellm-proxy.sh start
ℹ️ Activating virtualenv in /tmp/litellm
ℹ️ Creating claude settings file at /Users/suraj/.claude/settings.json
ℹ️ Creating litellm config file at /Users/suraj/.config/litellm/config.yaml
ℹ️ Starting litellm proxy server
INFO:     Started server process [94522]
INFO:     Waiting for application startup.

   ██╗     ██╗████████╗███████╗██╗     ██╗     ███╗   ███╗
   ██║     ██║╚══██╔══╝██╔════╝██║     ██║     ████╗ ████║
   ██║     ██║   ██║   █████╗  ██║     ██║     ██╔████╔██║
   ██║     ██║   ██║   ██╔══╝  ██║     ██║     ██║╚██╔╝██║
   ███████╗██║   ██║   ███████╗███████╗███████╗██║ ╚═╝ ██║
   ╚══════╝╚═╝   ╚═╝   ╚══════╝╚══════╝╚══════╝╚═╝     ╚═╝

...
INFO:     Uvicorn running on http://0.0.0.0:4000 (Press CTRL+C to quit)
...
```

### Running Claude Code

In a **separate terminal window**, launch Claude Code as usual:

```bash
claude
```

Claude Code will now connect to the litellm proxy instead of Anthropic's API, and your requests will be routed to GitHub Models!

### Stopping and Cleanup

When you're done, you can stop the proxy with `Ctrl+C`. The script automatically resets your Claude settings on exit.

If you want to manually reset Claude's configuration:

```bash
litellm-proxy.sh reset-claude
```

To completely remove all configurations and the virtual environment:

```bash
litellm-proxy.sh cleanup
```

## Why Use This Setup?

There are several compelling reasons to use Claude Code with GitHub Models:

1. **Cost Efficiency**: GitHub Models offers a free tier for testing and development
2. **Existing Infrastructure**: Leverage your existing GitHub subscriptions
3. **Rate Limits**: Different rate limits compared to direct Anthropic API access
4. **Experimentation**: Test Claude Code without committing to Anthropic API costs

## Conclusion

Using Claude Code with GitHub-hosted Anthropic models is a great way to not pay for the $20/month subscription, especially if you already have access to the GitHub models. The litellm-proxy setup makes this seamless with just a simple script.

Give it a try and let me know how it works for you! You can find the complete script and other utilities in my [dotfiles repository](https://github.com/surajssd/dotfiles).

## Resources

- [Claude Code Documentation](https://claude.ai/code)
- [GitHub Models](https://github.com/marketplace/models)
- [LiteLLM Proxy](https://github.com/BerriAI/litellm)
- [litellm-proxy.sh Script](https://github.com/surajssd/dotfiles/blob/master/local-bin/litellm-proxy.sh)
