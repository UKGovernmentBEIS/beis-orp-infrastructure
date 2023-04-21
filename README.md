# BEIS Terraform repo for AWS

This is the Terraform repository for the Open Regulatory Platform (ORP) deployed to AWS. This includes the definition for the front-end application, ingestion pipeline, graph database, search module, policies, roles, and supporting infrastructure.

The repository for the Lambda Functions used in the ingestion pipeline can be found [here](https://github.com/mdrxtech/beis-orp-data-service)

## Requirements

Before you can deploy the ORP using this Terraform configuration, you'll need the following:

- An AWS account with appropriate permissions to deploy the configuration
- AWS CLI installed
- Terraform installed (>= v1.3.3)
- AWS Credentials under a profile named `terraform`

## Installing/Deploying

To deploy the ORP, follow these steps:

1. Clone this repository to your local machine.
2. Navigate to the cloned repository in your terminal.
3. Run `terraform init` to initialize the Terraform configuration.
4. Run `terraform plan` to preview the changes that will be made.
5. If everything looks good, run `terraform apply` to deploy the pipeline.

### Updating the Configuration

If you need to update the configuration for the ORP, you can make changes to the Terraform configuration files and then run `terraform plan` and `terraform apply` as described above.
