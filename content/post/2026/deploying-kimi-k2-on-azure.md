---
author: "Suraj Deshmukh"
date: "2026-02-09T10:00:00+05:30"
title: "Deploying Kimi K2.5 on Azure: A Complete Guide to Running MoonshotAI's Model"
description: "Learn how to deploy and configure Kimi K2.5 on Azure AI Foundry with this step-by-step guide."
draft: false
categories: ["ai", "llm", "azure"]
tags: ["kimi", "ai", "llm", "azure", "moonshotai", "deployment", "cloud"]
cover:
  image: "/post/2026/images/kimi-k2.5-azure.png"
  alt: "Deploying Kimi K2.5 on Azure"
---

[Kimi K2.5](https://www.kimi.com/blog/kimi-k2-5.html) is [MoonshotAI's](https://www.moonshot.cn/) latest powerhouse, offering sophisticated reasoning capabilities and a massive context window. Now that it’s integrated into **Azure AI Foundry**, enterprise users can deploy it with the same security and scalability as the GPT family.

Beyond its raw specs, Kimi K2.5 is exciting because it has established itself as one of the premier OSS models for agentic workflows, proving to be a strong performer with frameworks like [OpenClaw](https://docs.openclaw.ai/).

In this guide, we’ll bypass the portal and use the Azure CLI to stand up a production-ready Kimi K2.5 instance.

## Prerequisites

Before running the scripts, ensure you have:

* An active **Azure Subscription**.
* **Azure CLI** installed ([Install guide](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)).
* Appropriate permissions to create Azure resources

## Step-by-Step Deployment

### 1. Set Up Environment Variables

First, let's define our deployment configuration. Update these variables according to your requirements:

```bash
export AZURE_SUBSCRIPTION_ID=$(az account show --query id --output tsv)
export AZURE_RESOURCE_GROUP="<your-resource-group-name>"
export AZURE_REGION="westus" # or other region where you have quota for AI services
export AZURE_AI_NAME="<your-ai-service-name>"
export AZURE_DEPLOYMENT_DOMAIN="<your-custom-domain>"
```

### 2. Create the Resource Group

Create a dedicated resource group for your Kimi K2.5 deployment (skip this if you are using an existing one):

```bash
az group create \
    --name "${AZURE_RESOURCE_GROUP}" \
    --location "${AZURE_REGION}" \
    --subscription "${AZURE_SUBSCRIPTION_ID}"
```

### 3. Create the Azure AI Services Account

Now, create the Azure AI Services account that will host your Kimi K2.5 model. Again, you can skip this step if you already have an AI Services account:

```bash
az cognitiveservices account create \
    --name "${AZURE_AI_NAME}" \
    --resource-group "${AZURE_RESOURCE_GROUP}" \
    --location "${AZURE_REGION}" \
    --kind AIServices \
    --sku S0 \
    --custom-domain "${AZURE_DEPLOYMENT_DOMAIN}" \
    --subscription "${AZURE_SUBSCRIPTION_ID}"
```

**Key parameters explained:**

* `--kind AIServices`: Specifies a multi-service AI resource
* `--sku S0`: The standard pricing tier. You can list available SKUs for your region using `az cognitiveservices account list-skus`
* `--custom-domain`: Creates a unique subdomain for your service (e.g., `https://<your-custom-domain>.services.ai.azure.com`)

### 4. Deploy the Kimi K2.5 Model

Configure the model deployment parameters:

```bash
export AZURE_DEPLOYMENT_NAME="kimi-k2-5-deployment" # You can choose any name for your deployment
export MODEL_NAME="Kimi-K2.5"
export MODEL_VERSION="1"
export MODEL_FORMAT="MoonshotAI"
```

Create the model deployment:

```bash
az cognitiveservices account deployment create \
    --name "${AZURE_AI_NAME}" \
    --resource-group "${AZURE_RESOURCE_GROUP}" \
    --deployment-name "${AZURE_DEPLOYMENT_NAME}" \
    --model-name "${MODEL_NAME}" \
    --model-version "${MODEL_VERSION}" \
    --model-format "${MODEL_FORMAT}" \
    --sku-capacity 20 \
    --sku-name "GlobalStandard"
```

**Important notes:**

* `--sku-name "GlobalStandard"`: Uses the global standard SKU for better availability. This is ideal for handling traffic bursts across Azure's global infrastructure
* `--sku-capacity 20`: Represents provisioned throughput (e.g., 20k tokens per minute). Adjust this based on your expected load and available quota

### 5. Configure API Access

Retrieve your API key and endpoint to verify connectivity:

```bash
export AZURE_API_KEY=$(az cognitiveservices account keys list \
    --name "${AZURE_AI_NAME}" \
    --resource-group "${AZURE_RESOURCE_GROUP}" \
    --subscription "${AZURE_SUBSCRIPTION_ID}" \
    --query key1 -o tsv)

export AZURE_ENDPOINT=$(az cognitiveservices account show \
    --name "${AZURE_AI_NAME}" \
    --resource-group "${AZURE_RESOURCE_GROUP}" \
    --subscription "${AZURE_SUBSCRIPTION_ID}" \
    --query "properties.endpoint" -o tsv)

echo "API Key: ${AZURE_API_KEY}"
echo "Endpoint: ${AZURE_ENDPOINT}"
```

## Testing Your Deployment

Once deployed, you can test your Kimi K2.5 instance using `curl`. Since Kimi supports the standard Chat Completions API / OpenAI like API, this payload will look familiar:

```bash
curl -X POST "https://${AZURE_DEPLOYMENT_DOMAIN}.services.ai.azure.com/models/chat/completions?api-version=2024-05-01-preview" \
    -H "Content-Type: application/json" \
    -H "api-key: ${AZURE_API_KEY}" \
    -d '{
        "messages": [
            {"role": "user", "content": "Hello, how are you?"}
        ],
        "max_tokens": 100,
        "model": "'"${AZURE_DEPLOYMENT_NAME}"'"
    }'
```

## Useful Azure CLI Commands

Here are some additional commands for managing your AI resources:

```bash
# List available AI service kinds
az cognitiveservices account list-kinds

# List available SKUs
az cognitiveservices account list-skus

# List available models
az cognitiveservices model list -l westus

# Check deployment status
az cognitiveservices account deployment show \
    --name "${AZURE_AI_NAME}" \
    --resource-group "${AZURE_RESOURCE_GROUP}" \
    --deployment-name "${AZURE_DEPLOYMENT_NAME}"

# Check quota and usage
az cognitiveservices usage list \
    -l ${AZURE_REGION} \
    --query "[?name.value=='AIServices.GlobalStandard.${MODEL_NAME}']"
```

## Azure Portal Access

You can also manage your deployment through the Azure Portal:

```bash
open "https://ai.azure.com/foundryResource/overview?wsid=/subscriptions/${AZURE_SUBSCRIPTION_ID}/resourceGroups/${AZURE_RESOURCE_GROUP}/providers/Microsoft.CognitiveServices/accounts/${AZURE_AI_NAME}"
```

## Conclusion

With just a few Azure CLI commands, you can have Kimi K2.5 up and running on Azure AI Foundry. This setup provides you with a powerful language model that's easy to integrate into your applications using the standard OpenAI API format, while leveraging Azure's enterprise-grade security and compliance.
