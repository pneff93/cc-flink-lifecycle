
resource "confluent_flink_compute_pool" "main_pool" {
  display_name     = "pneff-flink-demo"
  cloud            = var.cloud
  region           = var.region
  max_cfu          = 5
  environment {
    id = var.environment_id
  }
}

data "confluent_flink_region" "example" {
  cloud = var.cloud
  region = var.region
}

output "pool-id" {
  value = confluent_flink_compute_pool.main_pool.id
}

output "pool-rest-endpoint" {
  value = data.confluent_flink_region.example.rest_endpoint
}

