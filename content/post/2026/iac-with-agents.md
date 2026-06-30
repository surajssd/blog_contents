---
author: "Suraj Deshmukh"
date: "2026-06-29T10:00:00+05:30"
title: "Will AI Agents be the Death of YAML?"
description: "Exploring the impact of AI agents on the future of YAML in infrastructure as code."
draft: false
categories: ["ai", "llm", "infrastructure"]
tags: ["iac", "agents", "infrastructure", "automation"]
cover:
  image: "/post/2026/images/iac-with-agents/iac.png"
  alt: "Agent writing YAML vs. Code"
---

## Stop Making Agents Write YAML

At [@Scale: Systems and Reliability](https://atscaleconference.com/events/systems-reliability-2026/) this year, [Pulumi's](https://www.pulumi.com/) [Joe Duffy](https://www.linkedin.com/in/joejduffy) put a name to a problem a lot of us have been quietly routing around for years. He called it the "[agentic infrastructure gap](https://www.youtube.com/watch?v=P4PpoTH9ADc)."

The setup is familiar. [Andrej Karpathy](https://x.com/karpathy) has compared getting an app into production to assembling IKEA furniture: cloud consoles, API keys, configuration copied from somewhere, and a fair amount of duct tape holding it together. AI has accelerated application coding so dramatically that the bottleneck has completely shifted; writing the app is fast, but getting it running is the new hurdle. And the part that matters is that almost none of that deployment process lives anywhere an LLM can actually reason about.

![Karpathy tweet comparing shipping an app to assembling IKEA furniture](/post/2026/images/iac-with-agents/tweet.png)

[source](https://x.com/karpathy/status/1905051558783418370)

We've spent about a decade telling ourselves we do "infrastructure as code." Mostly we don't. We do infrastructure as configuration, and now that agents are in the loop, the difference is starting to cost us.

## The YAML problem

The story we told was that static formats like YAML, JSON, and whatever prevalent DSL the tool of the week shipped with were the safe choice. We told ourselves that they were declarative, readable, and hard to shoot yourself in the foot with.

Then systems got bigger and we needed actual logic. Instead of reaching for a programming language, we bolted logic onto whitespace-sensitive markup. That's where Helm templating and deep Kustomize overlay stacks come from. Then we added schemas, linters, and validators to keep the whole thing from falling over. We built an enormous amount of tooling whose only real job is to let us avoid writing software to deploy our software.

## Agents don't like it either

The assumption with capable agents was that they'd cheerfully take over the worst part: churning out the 5,000-line manifests nobody wants to write. In practice, they're not much happier doing it than we are.

Frontier models are trained on huge amounts of ordinary programming language — Python, TypeScript, Go, Rust. They've internalized control flow, type systems, how objects fit together. What they haven't internalized is your in-house DSL or some niche config format that barely exists in the training data. Ask an agent to hand-write a pile of that and you've pushed it out of distribution. It's IKEA furniture with the instructions missing. Furthermore, YAML lacks the strict reward signals, like passing tests and compile checks, that agents rely on to self-correct.

## Put it back in code

The fix, is that in-distribution languages "make it a coding problem," and that's the whole move. Define infrastructure in a real language, whether that's Pulumi, the Azure SDK, or AWS CDK, and the model gets to do the thing it's actually good at.

An agent can work an SDK without much trouble. It can follow a reference from application code into the infrastructure that backs it, use normal error handling, write a loop that means something, and produce deployment logic you can test. You still need an oracle — something that can tell you whether a given code change produced the infrastructure you actually wanted — but that's a tractable problem.

Your business logic stays where it should be: a tested artifact that doesn't change underneath you. The orchestration around it just goes back to being software.

So, the death of YAML? Not quite — it's still fine for the genuinely static stuff. What's ending is the reflex of reaching for it the moment we need logic. YAML was a convenience for humans who didn't want to maintain infrastructure code. An agent doesn't need the convenience. It needs an SDK.
