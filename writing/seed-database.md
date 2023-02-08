# How to Seed a Postgres Database on Azure with Bicep

Azure's infrastructure as Code (IaC) language Bicep us to easily configure and deploy a PostgreSQL database. Ideally, we want the required tables to be created during deployment, so that we don't have to do this manually after the deployment. However, automatically creating the desired schema and tables is not as trivial. This article covers the steps and code to seed a PostgreSQL database using Azure a `deploymentScripts` resource and a Managed Identity. 

