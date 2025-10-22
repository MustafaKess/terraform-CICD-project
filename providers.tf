terraform {
  required_version = ">= 1.0.0"

  # Store state locally for this assignment
  backend "local" {}
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.54"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2"
    }
  }
}

# Use environment variables for authentication:
# OS_AUTH_URL, OS_USERNAME, OS_PASSWORD, OS_TENANT_ID, etc.
provider "openstack" {}

provider "template" {}