# datagov-ssb

The Supplementary Service Broker (SSB) fills gaps in cloud.gov's brokered
services.

Services are defined in a
[brokerpaks](https://github.com/pivotal/cloud-service-broker/blob/master/docs/brokerpak-intro.md),
bundles of Terraform and YAML that specifies the service should be advertised,
provisioned, bound, unbound, and unprovisioned.

## Prerequisites

1. Credentials for an S3 bucket that will store the state of the broker
   deployment

    This will ensure multiple people who manage the state of the broker will not
    conflict with each other. See the [Terraform
    documentation](https://www.terraform.io/docs/state/remote.html) for more
    information.

    For example, you can [create an S3 service instance on
    cloud.gov](https://cloud.gov/docs/services/s3/#how-to-create-an-instance)
    using the `basic` plan, then [extract the
    credentials](https://cloud.gov/docs/services/s3/#interacting-with-your-s3-bucket-from-outside-cloudgov)
    for use.

1. cloud.gov credentials with permission to register the service broker in the
   spaces where it should be available.

    For example, you can create a `space-deployer` [cloud.gov Service
    Account](https://cloud.gov/docs/services/cloud-gov-service-account/) in one
    of the spaces. 
    
    Then you can grant the `SpaceDeveloper` role to the service account for additional
    spaces as needed: 
    
    ```
    cf set-space-role <accountname> <orgname> <spacename> SpaceDeveloper
    ```

1. Credentials to be used for managing resources in AWS

    See the instructions [for the necessary IAM
    policies](https://github.com/pivotal/cloud-service-broker/blob/master/docs/aws-installation.md#aws-service-credentials).

## Dependencies

The broker deployment is specified and managed using
[Terraform](https://www.terraform.io/). You must have at least Terraform version
`0.12.6` installed.

You must also [install the Terraform provider for Cloud
Foundry](https://github.com/cloudfoundry-community/terraform-provider-cf/wiki#using-the-provider)
```
bash -c "$(curl -fsSL https://raw.github.com/cloudfoundry-community/terraform-provider-cf/master/bin/install.sh)
```

## Creating and installing the broker
<!-- (TODO
Try to do this automatically with terraform... It seems possible with
github_release and github_actions_secret in the github_provider!) -->
1. Download the broker binary and any desired brokerpaks into the `/app`
   directory. 
    ```
    (cd app && curl -L -O https://github.com/pivotal/cloud-service-broker/releases/download/sb-0.1.0-rc.34-aws-0.0.1-rc.108/cloud-service-broker)
    (cd app && curl -L -O https://github.com/pivotal/cloud-service-broker/releases/download/sb-0.1.0-rc.34-aws-0.0.1-rc.108/aws-services-0.0.1-rc.108.brokerpak)

    ```

1. Copy the `backend.tfvars-template` and edit in the values for the S3 bucket.
    ```
    cp backend.tfvars-template backend.tfvars
    ${EDITOR} terraform.tfvars
    ```

1. Copy the `terraform.tfvars-template` and edit in the values for the Cloud
   Foundry service account and your IaaS deployer accounts.
    ```
    cp terraform.tfvars-template terraform.tfvars
    ${EDITOR} terraform.tfvars
    ```

1. Run Terraform init to set up the backend. You must provide the credentials
   for the S3 bucket as environment variables.
    ```
    AWS_ACCESS_KEY_ID="[redacted]" AWS_SECRET_ACCESS_KEY="[redacted]]" terraform init -backend-config=backend.tfvars
    ```
1. Run Terraform apply and answer `yes` when prompted.
    ```
    AWS_ACCESS_KEY_ID="[redacted]" AWS_SECRET_ACCESS_KEY="[redacted]]" terraform apply
    ```

# Uninstalling and deleting the broker
Run Terraform destroy and answer `yes` when prompted.
```
AWS_ACCESS_KEY_ID="[redacted]" AWS_SECRET_ACCESS_KEY="[redacted]]" terraform destroy
```

# Continuously deploying the broker

This repository includes a GitHub Action that can continuously deploy the
`master` branch for you. To configure it, fork this repository in GitHub, then enter the
following into [the `Settings > Secrets` page](/settings/secrets) on your fork:

| Secret Name | Description |
|-------------|-------------|
| AWS_ACCESS_KEY_ID | the S3 bucket key|
| AWS_SECRET_ACCESS_KEY | the S3 bucket  |
| BUCKET | the S3 bucket name |
| TF_VAR_AWS_ACCESS_KEY_ID | the key for brokering resources in AWS |
| TF_VAR_AWS_SECRET_ACCESS_KEY | the secret for brokering resources in AWS |

Once these secrets are in place, any changes to the master branch will be
deployed automatically.

---
## Contributing

See [CONTRIBUTING](CONTRIBUTING.md) for additional information.

## Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in
[CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright
> and related rights in the work worldwide are waived through the [CC0 1.0
> Universal public domain
> dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication.
> By submitting a pull request, you are agreeing to comply with this waiver of
> copyright interest.