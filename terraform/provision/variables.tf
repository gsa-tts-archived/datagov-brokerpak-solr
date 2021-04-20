variable "server" {
  type = string
}

variable "cluster_ca_certificate" {
  type        = string
  description = "The CA certificate (for your target k8s)"
}

variable "token" {
  type        = string
  description = "The service account token (for your target k8s)"
}

variable "namespace" {
  type        = string
  description = "The namespace (where you want SolrClouds deployed in your target k8s)"
}

variable "replicas" {
  type        = number
  description = "How many replicas to stand up in the SolrCloud instance (defaults to 3)"
  default     = 3
}

variable "solrImageTag" {
  type        = string
  description = "Tag for the Solr Docker image to use, defaults to 8.6. See https://hub.docker.com/_/solr?tab=tags for options"
  default     = "8.6"
}
variable "solrJavaMem" {
  type        = string
  description = "How much memory to give each replica (default is '-Xms4g -Xmx4g')"
  default     = "-Xms4g -Xmx4g"
}

variable "cloud_name" {
  type        = string
  description = "The name of the cloud to create (used only for demo purposes)"
  default     = "demo"
}

variable "domain_name" {
  type        = string
  description = "The domain to use for ingress (for your target k8s)"
  default     = "ing.local.domain"
}

variable "labels" {
  type        = map(any)
  description = "Labels for the created instance"
  default     = {}
}

locals {
  cloud_name = "solr-${substr(sha256(var.cloud_name), 0, 16)}"
}