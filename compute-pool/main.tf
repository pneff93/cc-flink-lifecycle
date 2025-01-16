
resource "confluent_flink_compute_pool" "main_pool" {
  display_name     = "pneff-flink-demo"
  cloud            = "GCP"
  region           = "europe-west1"
  max_cfu          = 5
  environment {
    id = var.environment_id
  }
}

resource "confluent_flink_statement" "create-table" {
  statement  = "CREATE TABLE orders_filtered AS SELECT * FROM orders where oderunits > 5;"
  properties = {
    "sql.current-catalog"  = var.environment_name
    "sql.current-database" = var.cluster_name
  }
  compute_pool {
    id = confluent_flink_compute_pool.main_pool.id
  }
}