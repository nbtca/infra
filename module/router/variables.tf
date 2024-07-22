variable "traefik_network" {
  type = object({
    name = string
    id   = string
  })
}
variable "cf_dns_api_token" {
  type = string
}


variable "host_name_base" {
  type = string
}
