---
author: "Suraj Deshmukh"
date: "2025-06-24T09:21:07-08:00"
title: "Deploying Grok-3 on Azure: A Complete Guide to Running xAI's Latest Model"
description: "Learn how to deploy and configure Grok-3 on Azure AI Foundry with this step-by-step guide. Set up your own instance of xAI's powerful language model in the cloud."
draft: false
categories: ["grok", "ai", "llm", "azure"]
tags: ["grok", "ai", "llm", "azure", "xai", "deployment", "cloud"]
cover:
  image: "/post/2025/images/azure-grok.png"
  alt: "Grok-3™️ deployment on Azure AI Foundry"
---

Grok-3 is [xAI's](https://x.ai/grok) latest language model that offers advanced reasoning capabilities and conversational AI features. With the release of Grok-3, xAI's latest and most powerful language model, [on Azure AI Foundry](https://devblogs.microsoft.com/foundry/announcing-grok-3-and-grok-3-mini-on-azure-ai-foundry/) every Azure user now has access to the model. In this guide, I'll walk you through the complete process of deploying Grok-3 on Azure, from setting up the infrastructure to making your first API calls.

## Prerequisites

Before we begin, make sure you have:

- An active Azure subscription
- Azure CLI installed and configured
- Appropriate permissions to create Azure resources

## Step-by-Step Deployment Guide

### 1. Set Up Environment Variables

First, let's define our deployment configuration. Update these variables according to your requirements:

```bash
export AZURE_RESOURCE_GROUP="name-of-your-resource-group"
export AZURE_AI_NAME="unique-name-for-your-ai-service"
export AZURE_SUBSCRIPTION_ID="your-subscription-id-here"
export AZURE_REGION="eastus2"
```

Set your active subscription:

```bash
az account set --subscription "${AZURE_SUBSCRIPTION_ID}"
```

### 2. Create the Resource Group

Create a dedicated resource group for your Grok-3 deployment:

```bash
az group create \
    --name "${AZURE_RESOURCE_GROUP}" \
    --location "${AZURE_REGION}" \
    --subscription "${AZURE_SUBSCRIPTION_ID}"
```

### 3. Create the Azure AI Services Account

Now, create the Azure AI Services account that will host your Grok-3 model:

```bash
az cognitiveservices account create \
    --name "${AZURE_AI_NAME}" \
    --resource-group "${AZURE_RESOURCE_GROUP}" \
    --location "${AZURE_REGION}" \
    --kind AIServices \
    --sku S0 \
    --custom-domain "${AZURE_AI_NAME}" \
    --subscription "${AZURE_SUBSCRIPTION_ID}"
```

**Key parameters explained:**

- `--kind AIServices`: Specifies a multi-service AI resource
- `--sku S0`: Standard pricing tier with good performance
- `--custom-domain`: Creates a custom subdomain for your service

### 4. Deploy the Grok-3 Model

Configure the model deployment parameters:

```bash
export MODEL="grok-3"
export MODEL_VERSION="1"
export MODEL_FORMAT="xAI"
```

Create the model deployment:

```bash
az cognitiveservices account deployment create \
    --name "${AZURE_AI_NAME}" \
    --resource-group "${AZURE_RESOURCE_GROUP}" \
    --deployment-name "${AZURE_AI_NAME}-${MODEL}" \
    --model-name "${MODEL}" \
    --model-version "${MODEL_VERSION}" \
    --model-format "${MODEL_FORMAT}" \
    --sku-capacity 1 \
    --sku-name "GlobalStandard"
```

**Important notes:**

- `--sku-name "GlobalStandard"`: Uses the global standard SKU for better availability
- `--sku-capacity 1`: Starts with minimal capacity (can be scaled up later)

### 5. Configure API Access

Retrieve your API key and set up the endpoint:

```bash
export AZURE_API_KEY=$(az cognitiveservices account keys list \
    --name "${AZURE_AI_NAME}" \
    --resource-group "${AZURE_RESOURCE_GROUP}" \
    --query key1 -o tsv)

export AZURE_API_ENDPOINT="https://${AZURE_AI_NAME}.services.ai.azure.com/models/chat/completions?api-version=2024-05-01-preview"
export AZURE_API_MODEL_NAME="${AZURE_AI_NAME}-${MODEL}"
```

### 6. Azure Portal Access

You can also manage your deployment through the Azure Portal:

```bash
open "https://ai.azure.com/foundryResource/overview?wsid=/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourceGroups/${AZURE_RESOURCE_GROUP}/providers/Microsoft.CognitiveServices/accounts/${AZURE_AI_NAME}"
```

## Testing Your Deployment

Once deployed, you can test your Grok-3 instance using curl:

```bash
curl -X POST "${AZURE_API_ENDPOINT}" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $AZURE_API_KEY" \
    -d '{
        "messages": [
            {
                "role": "user",
                "content": "I am going to Paris, what should I see?"
            }
        ],
        "max_completion_tokens": 2048,
        "temperature": 1,
        "top_p": 1,
        "frequency_penalty": 0,
        "presence_penalty": 0,
        "model": "'"${AZURE_API_MODEL_NAME}"'"
    }'
```

Notice that this is the same OpenAI API format, which makes it easy to integrate with existing applications.

## Using grok with OpenAI Codex

Codex is a powerful coding agent that runs from CLI. You can use it to talk to the Grok-3 model deployed on Azure. Once you install the Codex CLI, you would need to create a configuration file. Run the following command to create a configuration file:

```toml
mkdir -p ~/.codex
cat << EOF | tee -a ~/.codex/config.toml
[model_providers.azure]
name = "Azure"

base_url = "https://${AZURE_AI_NAME}.services.ai.azure.com/models"
env_key = "AZURE_API_KEY"

# Newer versions appear to support the responses API, see https://github.com/openai/codex/pull/1321
query_params = { api-version = "2024-05-01-preview" }

[profiles.grok]
model_provider = "azure"
model = "${AZURE_AI_NAME}-${MODEL}"
EOF
```

Now you can start using the codex CLI to interact with Grok-3:

```bash
codex -p grok "Explain this project to me?"
```

> [!NOTE]:
> You have to have the environment variable `AZURE_API_KEY` set in your shell for the Codex CLI to work properly.

## Useful Azure CLI Commands

Here are some additional commands that might be helpful:

```bash
# List available AI service kinds
az cognitiveservices account list-kinds

# List available SKUs
az cognitiveservices account list-skus

# List available models
az cognitiveservices model list

# Check deployment status
az cognitiveservices account deployment show \
    --name "${AZURE_AI_NAME}" \
    --resource-group "${AZURE_RESOURCE_GROUP}" \
    --deployment-name "${AZURE_AI_NAME}-${MODEL}"
```

## Conclusion

This tutorial can be easily automated, allowing you to deploy Grok-3 on Azure with just a few commands.
