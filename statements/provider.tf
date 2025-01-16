# Configure the Confluent Provider
terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "2.12.0"
    }
  }
}

data "terraform_remote_state" "compute-pool" {
  backend = "local"
  config = {
    path = "../compute-pool/terraform.tfstate"
  }
}

provider "confluent" {
  organization_id       = var.org_id
  environment_id        = var.environment_id
  flink_compute_pool_id = data.terraform_remote_state.compute-pool.outputs.pool-id
  flink_rest_endpoint   = data.terraform_remote_state.compute-pool.outputs.pool-rest-endpoint
  flink_api_key         = var.flink_api_key
  flink_api_secret      = var.flink_api_secret
  flink_principal_id    = var.flink_sa_id
}