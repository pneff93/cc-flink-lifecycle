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

variable "environment_id" {
  description = "CC Environment"
  type = string
}

variable "cloud" {
  description = "Cloud"
  type = string
}

variable "region" {
  description = "Cloud region"
  type = string
}