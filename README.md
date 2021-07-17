# Azure Private Link Demo

This is a demo showing the usage of private link when using Azure Fileshare in an Enterprise Setting.

# Infrastructure Diagram

![Architecture Diagram](assets/infra-architecture.png)

# Infrastructure Breakdown

**Infrastructure:**
Here is a Hybrid architecture built on Microsoft Azure. The Azure Network Architecture is a traditional Hub and Spoke with vnet connectivity using Vnet Peering.
To simulate an onprem environment, I used a vnet called on-premise vnet and added a VPN Gateway to simulate an on-prem VPN device that will connect to an Azure vnet using a S2S VPN link.

# Infrastructure Component

## AD and DNS

Active Directory is deployed on VM's both on the on-prem vnet and on the Hub vnet.

## Private Link

I am using Azure Private Link Service to deploy an Azure Private endpoint inside the Hub vnet. This deploys a read-only NIC to be able to reach our fileshare service privately using a private IP address i.s.o. the public ip address.
Because I am leveraging the Hub and Spoke architecture, the spoke vnet can access the fileshare as well. The onprem vnet can access it as well due to the connectivity via VPN Gateway.

## Authentication

Leveraging Traditional Active Directory authentication and permissions on the Azure fileshares using a combination of scripts and DNS configurations.

# How to deploy the Infrastructure on your environment?

### Using the Deploy to Azure button to deploy via the Portal

https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-to-azure-button

### Using Azure Devops Pipeline

Running the pipeline will do the following:

1. Check out the code

2. Build the and test the code base

3. Publish Artifact (ARM template) to build the infrastructure for the 3 stages

4. Deploy to DEV, STG and PRD stage

5. There is a destroy stage (Using pipeline approval). Click on it to review and approve to destroy the whole infrastructure built

# Prerequisite:

- **Azure DevOps account:** we will use an Azure DevOps project with a Github repo and build/release pipelines. Create your free account and a new project [here](https://azure.microsoft.com/services/devops/).

- **Azure Subscription:** An azure subscription is needed to provision the Azure services for this demonstration. If you don’t have one, you can get a free trial one [here](https://azure.microsoft.com/free/). Create an azure DevOps project

- **Bash Shell:** we will leverage Azure Cloud Shell. Once your Azure Subscription is set up you can enable and use your associated [Azure Cloud Shell](https://docs.microsoft.com/azure/cloud-shell/overview) session. Notes: you could use any local bash terminal. Make sure you have [installed the Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)

- **Service Principal:** we will leverage SPN with contributor access to create resources on Azure from Azure DevOps

# Create a resource group in Azure

    #Login to Azure
    az login
    #Set subscription
    az account set --subscription <subscription  id>
    #Create Resource Group
    #az group create --name <rgname> --location <region>
    az group create --name spring-demo --location 'West Europe'

**To create a Service Principal Name**

       #az ad sp create-for-rbac --name <service-principal-name>
       az ad sp create-for-rbac --name SpringSpn

## Create a Build / Continuous Integration (CI) pipeline and continuous delivery (CD)

Create a service connection for the pipeline using the details of the service principal created earlier

![Service Connection](assets/serviceconnection.png)

**Fill the following details:**

- **Subscription ID:** < Your Subscription ID>
- **Subscription Name:** < subscription name>
- **Service principal id:** < Service principal Id>
- **Service principal Key:** < Service Principal Key>
- **Tenant ID :** < Your Tenant ID>
- **Service Connection Name:** <Service  connection  Name> This will be referenced in the YAML pipeline
- **Click on save and verify**

## Create a multi Stage pipeline with Yaml

First fork the [repo](https://github.com/abulina/azureprivatelinkdemo) by clicking on the fork icon on the top right

![forkrepo](assets/repofork.png)

Navigate to your DevOps project and Create a pipeline by clicking on the Pipeline icon

![createpipeline](assets/pipelinecreate.png)

Click on **New Pipeline** and select **GitHub (YAML)**

![createnewpipeline](assets/newpipeline.png)

Login to Github and authorize it for Azure DevOps. Select the forked repo and it will automatically pick the azure-pipeline.yml file in the repo which contains the YAML template for the build and release stage. Click on **Save and Run** to run the pipeline

![pipelinerun](assets/runpipeline.png)

**See a complete build and release below:**

![buildstages](assets/completebuild.jpeg)
