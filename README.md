# IaC Assignment 2 – Terraform CI/CD Workflow

### Small note!
This project was originally built on NTNU's own github instance and later cloned and pushed up here. This means when you take a look at github actions it wont show you any history from the runner. But there were atleast 60 workflow runs (be it manual activations on the different environments or automatic triggers on push) 

I would also note that since this project was a part of a university course. The openstack instance that my GitHub runner was active on was shut down at the end of 2025. So any attempt to activate the GitHub actions will fail unless i host a new one. 

<img width="1717" height="714" alt="image" src="https://github.com/user-attachments/assets/d57e8ce9-c688-43f6-bc8d-5974370a466b" />




  ## Overview

  This repository contains the TerraTech infrastructure-as-code (IaC) setup for Assignment 2.  
  The goal is to demonstrate a multi-environment Terraform workflow using GitHub Actions, applied to OpenStack.

  This includes:

  - Testing (`test`), Staging (`staging`), and Production (`prod`) environments
  - Terraform modules for network, frontend, database, and optional load balancer
  - Environment-specific configurations via `tfvars` files
  - CI/CD workflow for **planning Terraform deployments**

  ---

  ## Repository Structure
```
IaC-assignment2/
├── .github/workflows/terraform_runner_flow.yml    # Workflow
├── modules/                                       # These are mostly unchanged from the first assignment
│   ├── network/
│   ├── frontend/
│   ├── database/
│   └── loadbalancer/
├── tfvars/                                        # For the different enviroments 
│   ├── dev.tfvars
│   ├── test.tfvars
│   ├── staging.tfvars
│   └── prod.tfvars
├── .pre-commit-config.yaml 
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
└── README.md
```


---

## Prerequisites

- OpenStack account with proper credentials (`OS_USERNAME`, `OS_PASSWORD`, `OS_TENANT_ID`, `OS_AUTH_URL`)
- SSH key pair registered in OpenStack (used in `tfvars`)
- Self-hosted GitHub runner labeled `terraform-runner`

### GitHub Secrets
These are repository secrets that are stored as hidden enviroments for handling credentials for OpenStack useage. 

| Secret        | Description                       |
|---------------|-----------------------------------|
| OS_USERNAME   | OpenStack username                |
| OS_PASSWORD   | OpenStack password                |
| OS_TENANT_ID  | OpenStack tenant/project ID       |
| OS_AUTH_URL   | OpenStack authentication URL      |

---

These are all provided in GitHub secrets for this repository. This project isn't meant to be ran locally using terraform CLI. But you could using the same credential method from assignment 1 as well as adding `export TF_VAR_db_password=$OS_PASSWORD ` in the openrc.sh script.

## GitHub Actions Workflow

The GitHub Actions workflow is located at `.github/workflows/terraform_runner_flow.yml`.

It is divided into three main jobs:

1. **Validate**  
   - Runs `terraform init` and `terraform validate` on the selected environment.
   - Ensures that the Terraform configuration is syntactically correct before planning or applying.
   - Uses environment variables from GitHub secrets for OpenStack authentication.

2. **Plan**  
   - Runs after the `validate` job.
   - Executes `terraform plan` using the appropriate `tfvars` file for the environment:
     - `tfvars/test.tfvars`
     - `tfvars/staging.tfvars`
     - `tfvars/prod.tfvars`
   - Generates an execution plan showing what changes Terraform would apply, without making any changes.

3. **Apply**  
   - Runs after the `plan` job.
   - Requires a manual approval in GitHub if the environment is `prod`.
   - Executes `terraform apply` on the selected environment.
   - Automatically uses the corresponding `tfvars` file.

### Workflow Trigger

- **Push** to the `main` branch.
- **Manual dispatch** via the GitHub Actions UI with a dropdown to select the environment (`test`, `staging`, `prod`).


### Pre-commit Integration

Before commits or pushes, a pre-commit pipeline ensures Terraform code quality:

```yaml
- repo: https://github.com/antonbabenko/pre-commit-terraform
  rev: v1.83.5
  hooks:
    - id: terraform_fmt
    - id: terraform_validate
    - id: terraform_tflint
    - id: terraform_tfsec
    - id: terraform_checkov
```

(The checkov and tflint is mainly the reason why there has been little progress made after early last week, had to spend a lot of time satisfying those requirements and then deal with issues following me "satisfying" those requirements)




### Example

To run a plan for the staging environment manually:

1. Go to the repository → Actions → Terraform runner_flow → Run workflow.
2. Select `staging` as the environment.
3. Workflow runs `terraform init`, `validate`, and `plan` for `tfvars/staging.tfvars`.


### Final notes and short-commings
- Currently there are no remote state management, this causes terraform destroy to destroy 0 elements, so thats why terraform destroy not implemented. I tried to do a solution using GitLab remote state enviroments but it ended up causing a lot of issues so i cut it off.
- Because of no state. The runners will make new security groups and volumes for each apply. This may cause it to reach the quota and fail the terraform apply which causes me to manually have to delete them in openstack
- This manual completeion made me accidentally delete the runner instance the same day as the due date which caused a lot of headache and made me use precious polishing time on that instead 

