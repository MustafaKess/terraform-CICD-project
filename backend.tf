terraform {
  backend "http" {
    address        = "https://gitlab.com/api/v4/projects/${var.gitlab_project_id}/terraform/state/${var.state_name}"
    lock_address   = "https://gitlab.com/api/v4/projects/${var.gitlab_project_id}/terraform/state/${var.state_name}/lock"
    unlock_address = "https://gitlab.com/api/v4/projects/${var.gitlab_project_id}/terraform/state/${var.state_name}/lock"
    username       = "gitlab-ci-token"
    password       = var.gitlab_token
    lock_method    = "POST"
    unlock_method  = "DELETE"
    retry_wait_min = 5
  }
}
