---
author: "Suraj Deshmukh"
date: "2026-10-02T10:20:00-07:00"
title: "Visualizations for the book 'AI Systems Performance Engineering'"
description: "Interactive diagrams and animations for the first two chapters of AI Systems Performance Engineering: training compute, GB200 NVL72 throughput, Grace Blackwell hardware, and the NVLink fabric."
draft: false
categories: ["ai", "llm"]
tags: ["ai", "llm", "visualization", "gpu", "training", "blackwell", "cuda"]
cover:
  image: "/post/2026/images/ai-systems-performance-engineering.png"
  alt: "AI Systems Performance Engineering book cover"
---

I am working through **[AI Systems Performance Engineering](https://www.oreilly.com/library/view/ai-systems-performance/9798341627772/)** by **[Chris Fregly](https://fregly.com/)**. The first two chapters cover training compute estimates and the hardware that runs those workloads. I put together these visualizations to follow the calculations and see how the components connect.

Like my [visualizations for Inference Engineering](/post/2026/inference-engineering-visualizations/), these are companions to specific parts of the book. Each link below includes its chapter so you can open the relevant diagram as you read.

## How to use them

Open an interactive page from the links below. Hover over the diagrams or use the Tab key to focus their elements for more detail. The charts also have a table view, and the pages follow your device's light or dark setting.

The animations below explain the hardware with on-screen labels. They have no audio.

## The visualizations

- **[Training compute: where C ≈ 6ND comes from](/share/books/ai-systems-performance-engineering/ch01-6nd-training-flops.html)** (Chapter 1, "Toward 100-Trillion-Parameter Models"): breaks down the operations in the forward and backward passes, then compares training compute estimates across models.
- **[GB200 NVL72: where 1.44 exaFLOPS comes from](/share/books/ai-systems-performance-engineering/ch01-gb200-nvl72-peak-flops.html)** (Chapter 1, "NVIDIA's 'AI Supercomputer in a Rack'"): shows how per-GPU throughput, numeric precision, structured sparsity, and the rack's 72 GPUs contribute to the quoted peak.
- **[Grace Blackwell: how the CPU accesses GPU memory](/share/books/ai-systems-performance-engineering/ch02-grace-blackwell-unified-memory.html)** (Chapter 2, "AI System Hardware Overview"): traces the paths between CPU and GPU memory and compares the bandwidth available on each path.

## The Grace Blackwell superchip, animated

This animation accompanies Chapter 2's "The CPU and GPU Superchip" section. It walks through the Grace CPU, the two Blackwell GPUs, their memory, and the links between them.

{{< youtube id="Q7myvCmf1eg" title="The Grace Blackwell superchip, animated" loading="lazy" >}}

The animation runs for 3 minutes and 33 seconds. You can also [watch it on YouTube](https://youtu.be/Q7myvCmf1eg).

## Inside the SM, animated

This animation accompanies Chapter 2's "Streaming Multiprocessor, Threads, and Warps" section. It shows what a streaming multiprocessor (SM) contains and how the GPU memory hierarchy is laid out. It then shows how an SM runs threads in warps of 32 and hides memory latency by switching between warps.

{{< youtube id="0NxdbAUB1V8" title="Inside the SM, animated" loading="lazy" >}}

The animation runs for 3 minutes and 8 seconds. You can also [watch it on YouTube](https://youtu.be/0NxdbAUB1V8).

## NVLink and NVSwitch, animated

This animation accompanies Chapter 2's "NVLink and NVSwitch" section. It shows how a GB200 NVL72 rack is laid out, the 18 NVLink ports on each Blackwell GPU, and the 144 ports on each NVLink Switch tray. It then shows how every GPU is wired to every NVSwitch chip and how data moves from one GPU to another in a single hop.

{{< youtube id="nL2D-rkvnNI" title="NVLink and NVSwitch, animated" loading="lazy" >}}

The animation runs for 3 minutes and 6 seconds. You can also [watch it on YouTube](https://youtu.be/nL2D-rkvnNI).
