variable "cf_dns_api_token" {
  description = "API token for Cloudflare DNS"
  type        = string
  sensitive   = true
}

variable "ssh_user" {
  description = "SSH user"
  type        = string
  default     = "terraform"
}

variable "ssh_key" {
  description = "SSH private key path"
  type        = string
  default     = "$HOME/.ssh/terraform_rsa"
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
