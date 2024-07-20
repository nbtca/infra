variable "docker_host" {
  default = "ssh://sgp"
  type    = string
}


variable "cf_dns_api_token" {
  description = "API token for Cloudflare DNS"
  type        = string
  sensitive   = true
}

variable "cluster" {
  description = "Name of the cluster"
  type = list(
    object({
      hostname        = string
      public_address  = string
      private_address = string
      tags            = map(string)
    })
  )
}
