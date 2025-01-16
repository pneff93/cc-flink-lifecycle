variable "cloud_api_key" {
  description = "Confluent Cloud API Key"
  type = string
  sensitive = true
}

variable "cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type = string
  sensitive = true
}

variable "org_id" {
  description = "CC Organization"
  type = string
}

variable "environment_id" {
  description = "CC Environment"
  type = string
}

variable "environment_name" {
  description = "Name of the environment"
  type = string
}

variable "cluster_name" {
  description = "Name of the CC cluster"
  type = string
}