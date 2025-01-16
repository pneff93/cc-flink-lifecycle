variable "org_id" {
  description = "CC Organization"
  type = string
}

variable "environment_id" {
  description = "CC Environment"
  type = string
}

variable "environment_name" {
  description = "CC Environment name"
  type = string
}

variable "cluster_name" {
  description = "CC Cluster name"
  type = string
}

variable "flink_sa_id" {
  description = "SA for Flink statements"
  type = string
}

variable "flink_api_key" {
  description = "API Key for Flink statements"
  type = string
}

variable "flink_api_secret" {
  description = "API Secret for Flink statements"
  type = string
  sensitive = true
}
