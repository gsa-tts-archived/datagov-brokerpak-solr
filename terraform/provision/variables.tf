
variable "instance_name" {
  type        = string
  description = "Unique ID to separate solr instanceresources"
}

variable "region" {
  type        = string
  description = "region to create solr ecs cluster"
  default     = "us-west-2"
}

variable "labels" {
  type    = map(any)
  default = {}
}

variable "zone" {
  type        = string
  description = "DNS Zone to host Solr service"
}

variable "solrImageRepo" {
  type        = string
  description = "Repository for the Solr Docker image to use, defaults to docker.io/solr"
  default     = "docker.io/solr"
}

variable "solrImageTag" {
  type        = string
  description = "Tag for the Solr Docker image to use, defaults to 8.6. See https://hub.docker.com/_/solr?tab=tags (or your configured solrImageRepo) for options"
  default     = "8.11"
}

variable "solrMem" {
  type        = number
  description = "How much memory to request for each replica (default is '12G')"
  default     = 12288
}

variable "solrCpu" {
  type        = number
  description = "How much vCPU to request for each replica (default is '2048' aka '2 vCPUs')"
  default     = 2048
}
