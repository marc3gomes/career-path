
# AWS Glue, Athena, and S3 Integration using Terraform

## Project Overview

This repository is designed as a study and research project for learning how to set up and manage data pipelines and analytics using **AWS Glue**, **Athena**, and **S3**. The project provisions resources in AWS to enable data processing using Terraform and explores key cloud services such as Glue Crawlers, S3 storage, and Athena queries.

This project is not intended for production usage but rather as a learning tool for exploring AWS cloud services in data engineering.

## Key Features

- Provisioning of AWS resources using **Terraform**:
  - S3 Buckets for storing data and Athena query results.
  - Glue database and crawler to automatically detect schema from Parquet files stored in S3.
  - IAM roles and policies for securely accessing S3, Glue, and Athena services.
  
- **GitHub Actions Pipeline**: This repository uses GitHub Actions to automate uploading data files (e.g., Parquet) to the S3 bucket for analysis and processing.

## Pre-requisites

### Tools and Technologies Required

To run this project, you'll need the following installed on your local machine:

- [Terraform CLI](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- An AWS account with appropriate permissions (explained below).

### AWS IAM Permissions

To deploy and run this project, your AWS IAM user needs specific permissions. Ensure that your IAM user has the following **managed policies** attached:

1. `AmazonS3FullAccess`
2. `AWSGlueConsoleFullAccess`
3. `AmazonAthenaFullAccess`
4. `AWSLambda_FullAccess`
5. `AmazonAPIGatewayAdministrator`
6. `AWSGlueServiceRole`
7. `IAMUserChangePassword`

In addition, you'll need to create a **custom IAM policy** with the following permissions to manage roles and policies in your environment:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole",
        "iam:AttachRolePolicy",
        "iam:PutRolePolicy",
        "iam:CreatePolicy",
        "iam:DeleteRole",
        "iam:DeletePolicy",
        "iam:PassRole",
        "iam:DeleteRolePolicy",
        "iam:ListInstanceProfilesForRole",
        "iam:DetachRolePolicy",
        "iam:ListPolicyVersions"
      ],
      "Resource": "*"
    }
  ]
}
```

For further details on how to create a custom policy, refer to the [AWS Documentation on IAM Policies](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_create-console.html).

## Project Structure

The Terraform code in this repository provisions the following AWS resources:

- **S3 Buckets**:
  - `career-path-terraform-studies`: Stores Parquet files for analysis.
  - `athena-query-results-career-path`: Stores query results from Athena.
  
- **Glue Database and Crawler**:
  - A Glue database called `career_path_db`.
  - A Glue Crawler that automatically detects the schema of Parquet files in the S3 bucket and updates the Glue Data Catalog.

- **IAM Roles and Policies**:
  - IAM Roles for Glue and Athena with the required policies for accessing S3 and managing the Glue Data Catalog.

## How to Run

1. **Clone the repository**:
   ```bash
   git clone https://github.com/marc3gomes/career-path
   cd career-path
   ```

2. **Configure AWS credentials**:
   Ensure that you have your AWS credentials configured locally. You can configure them using:
   ```bash
   aws configure
   ```
   Make sure the IAM user you're using has all the necessary permissions mentioned above.

3. **Initialize Terraform**:
   Initialize your Terraform environment by running:
   ```bash
   terraform init
   ```

4. **Deploy the infrastructure**:
   Apply the Terraform configurations to provision the AWS resources:
   ```bash
   terraform apply
   ```

5. **Query the Data**:
   After the Glue Crawler detects the schema, you can query the data in **Athena** using:
   ```sql
   SELECT * FROM "career_path_db"."data" LIMIT 10;
   ```

## Important Notes

- **Pipeline Automation**: We use GitHub Actions to automatically upload data files (e.g., Parquet) to S3 after the Terraform workflow completes. This ensures that the data is ready for processing by AWS Glue and Athena.
  
- **Disclaimer**: This repository is for educational purposes only. It is recommended that you do not use this configuration in a production environment without thoroughly reviewing and testing the security and performance considerations.

## Resources

- [AWS Glue Documentation](https://docs.aws.amazon.com/glue/index.html)
- [AWS Athena Documentation](https://docs.aws.amazon.com/athena/index.html)
- [Terraform Documentation](https://www.terraform.io/docs/index.html)
