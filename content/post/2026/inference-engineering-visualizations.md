---
author: "Suraj Deshmukh"
date: "2026-08-02T10:00:00+05:30"
title: "Interactive Visualizations for the book 'Inference Engineering'"
description: "A set of interactive, self-contained visualizations that make the core concepts of inference engineering — dimensionality, attention, MoE, and the roofline model — tangible."
draft: false
categories: ["ai", "llm"]
tags: ["ai", "llm", "inference", "visualization", "transformers", "attention", "mixture-of-experts"]
---

I have been working through **[Inference Engineering](https://www.baseten.co/inference-engineering/)** by **[Philip Kiely](https://philipkiely.com/)** — a book for engineers who want to understand the technologies that power every AI company and application in the world. Along the way I built a handful of interactive visualizations to make some of the denser chapters click for me. Reading about attention or the roofline model is one thing; being able to drag a slider and watch the numbers move is another.

These are companions to specific sections of the book, not a replacement for it. Each one maps to a section number so you can read the corresponding chapter and then come play with the idea here.

## How to use them

Each visualization is a single, self-contained page — no dependencies, no tracking, dark/light aware. Open any of them in a new tab and start poking at the controls.

## The visualizations

- **[Dimensionality, Visualized](https://suraj.io/share/books/inference-engineering/2.1-dimensionality.html)** (§2.1) — how the model, sequence, and batch dimensions compose, and where the shapes flowing through a transformer come from.
- **[Activation Functions, Visualized](https://suraj.io/share/books/inference-engineering/2.1.2-activations.html)** (§2.1.2) — the common activation functions side by side, and how each one shapes the signal.
- **[The Transformer Pipeline, Visualized](https://suraj.io/share/books/inference-engineering/2.2.2-transformer-blocks.html)** (§2.2.2) — a walk through a transformer block end to end, from input embeddings out the other side.
- **[Attention, Visualized](https://suraj.io/share/books/inference-engineering/2.2.3-attention.html)** (§2.2.3) — how queries, keys, and values interact to produce the attention pattern.
- **[Mixture of Experts, Visualized](https://suraj.io/share/books/inference-engineering/2.2.4-moe-models.html)** (§2.2.4) — routing tokens to experts, and how sparse activation changes the compute story.
- **[Roofline, Ops:Byte & Arithmetic Intensity](https://suraj.io/share/books/inference-engineering/2.4.1-roofline-ops-byte.html)** (§2.4.1) — the roofline model, and how arithmetic intensity decides whether you are compute- or memory-bound.

If you spot something wrong or have an idea for another section worth visualizing, let me know.
