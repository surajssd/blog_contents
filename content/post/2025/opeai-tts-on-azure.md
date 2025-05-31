---
author: "Suraj Deshmukh"
date: "2025-05-31T09:21:07-08:00"
title: "Deploying OpenAI Text-to-Speech (TTS) Model on Azure: A Step-by-Step Guide"
description: ""
draft: false
categories: ["openai", "ai", "llm", "azure", "tts"]
tags: ["openai", "ai", "llm", "azure", "tts"]
cover:
  image: "/post/2025/images/azure-openai-tts.png"
  alt: "TTS on Azure"
---

# Deploying OpenAI Text-to-Speech (TTS) Model on Azure: A Step-by-Step Guide

Azure Cognitive Services provides a straightforward way to deploy OpenAI models, including powerful text-to-speech capabilities. In this guide, I’ll demonstrate how to deploy a text-to-speech model using Azure CLI commands.

## Prerequisites

* An Azure subscription
* Azure CLI installed and logged in (`az login`)

## Step 1: Define Environment Variables

Set your environment variables to simplify and standardize deployments.

```bash
export AZURE_RESOURCE_GROUP="example-rg"
export AZURE_REGION="eastus"
export OPENAI_NAME="example-openai"
export AZURE_SUBSCRIPTION_ID="your-subscription-id"

# Keep these variables as is.
export AUDIO_MODEL="gpt-4o-mini-tts"
export AUDIO_MODEL_VERSION="2025-03-20"
```

**Explanation:**

* `AZURE_RESOURCE_GROUP`: Azure Resource Group name. Choose a unique name for your resource group to contain all related resources.
* `AZURE_REGION`: Azure region where resources will be created. Common regions include `eastus`, `westus`, `westeurope`, etc.
* `OPENAI_NAME`: Unique name for your OpenAI resource. This will be used to access your deployed model.
* `AZURE_SUBSCRIPTION_ID`: Azure subscription identifier. You can find this in your Azure portal under "Subscriptions".
* `AUDIO_MODEL`: The specific model you want to deploy. For text-to-speech, `gpt-4o-mini-tts` is a suitable choice.
* `AUDIO_MODEL_VERSION`: The version of the model you wish to use. This should match the version available in Azure OpenAI service.

## Step 2: Create Resource Group

Create a resource group to contain your OpenAI resources, if it doesn't already exist, by running the following command:

```bash
az group create \
  --name "${AZURE_RESOURCE_GROUP}" \
  --location "${AZURE_REGION}" \
  --subscription "${AZURE_SUBSCRIPTION_ID}"
```

## Step 3: Create Cognitive Services Account

Create an Azure Cognitive Services account for hosting your OpenAI model:

```bash
az cognitiveservices account create \
  --name "${OPENAI_NAME}" \
  --resource-group "${AZURE_RESOURCE_GROUP}" \
  --location "${AZURE_REGION}" \
  --kind OpenAI \
  --sku S0 \
  --custom-domain "${OPENAI_NAME}" \
  --subscription "${AZURE_SUBSCRIPTION_ID}"
```

**Explanation:**

* `--name`: Sets the unique name for the service.
* `--kind`: Specifies the kind of service (OpenAI).
* `--sku`: Selects the pricing tier (S0 is standard).
* `--custom-domain`: Custom domain name for accessing the service.

## Step 4: Deploy the OpenAI Model

Deploy your chosen model (`gpt-4o-mini-tts`) to your account:

```bash
az cognitiveservices account deployment create \
  --name "${OPENAI_NAME}" \
  --resource-group "${AZURE_RESOURCE_GROUP}" \
  --deployment-name "${OPENAI_NAME}-${AUDIO_MODEL}" \
  --model-name "${AUDIO_MODEL}" \
  --model-version "${AUDIO_MODEL_VERSION}" \
  --model-format OpenAI \
  --sku-capacity 1 \
  --sku-name "GlobalStandard"
```

**Explanation:**

* `--deployment-name`: Unique name for this specific model deployment.
* `--model-name`: The OpenAI model to deploy.
* `--model-version`: Specific version of the model.
* `--model-format`: Format of the model (OpenAI).
* `--sku-capacity`: Number of instances allocated for the deployment.
* `--sku-name`: SKU type that dictates the availability and performance.

## Step 5: Retrieve API Key

Fetch the API key necessary for accessing your deployed model:

```bash
export AZURE_OPENAI_API_KEY=$(az cognitiveservices account keys list \
  --name "${OPENAI_NAME}" \
  --resource-group "${AZURE_RESOURCE_GROUP}" \
  --query key1 -o tsv)
```

**Explanation:**

* `--query key1`: Retrieves the primary key of your Cognitive Services account.
* `-o tsv`: Outputs the result in a tab-separated format for easy scripting.

## Step 6: Set Endpoint URL

Create an environment variable for your model endpoint:

```bash
export OPENAI_ENDPOINT="https://${OPENAI_NAME}.openai.azure.com/openai/deployments/${OPENAI_NAME}-${AUDIO_MODEL}/audio/speech?api-version=2025-04-01-preview"
```

## Verify Deployment with cURL

To verify your deployment, run the following cURL command:

```bash
curl "$OPENAI_ENDPOINT" \
 -H "api-key: $AZURE_OPENAI_API_KEY" \
 -H "Content-Type: application/json" \
 -d '{
  "model": "gpt-4o-mini-tts",
  "input": "I am excited to try text to speech.",
  "voice": "alloy",
  "instructions": "Speak in a cheerful and positive tone."
 }' --output speech.mp3
```

**Explanation:**

* Sends a POST request to the OpenAI endpoint.
* `-H`: Includes headers specifying API key and content type.
* `-d`: Defines the JSON payload with model details, input text, voice choice, and speaking instructions.
* `--output`: Saves the generated speech audio to `speech.mp3`.

## Summary

You've successfully deployed an OpenAI text-to-speech model on Azure. You can now leverage Azure's powerful infrastructure and your custom deployment to build advanced audio-based applications. Always ensure you securely handle your API keys in production environments.
