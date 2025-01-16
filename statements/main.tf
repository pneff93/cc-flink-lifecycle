
resource "confluent_flink_statement" "create-table" {
  statement  = "CREATE TABLE orders_filtered DISTRIBUTED INTO 1 BUCKETS AS SELECT * FROM orders where orderunits > 5;"
  properties = {
    "sql.current-catalog"  = var.environment_name
    "sql.current-database" = var.cluster_name
  }
}