variable "docker_host" {
  default = "ssh://sgp"
  type      = string
}


variable "cf_dns_api_token" {
  description = "API token for Cloudflare DNS"
  type      = string
  sensitive = true
}
