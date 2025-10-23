terraform {
  required_version = ">= 1.0.0"

  backend "local" {}

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.54.1"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2"
    }
  }
}

provider "openstack" {}
provider "template" {}
