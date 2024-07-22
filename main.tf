terraform {
  # $ export PG_CONN_STR=postgres://user:pass@db.example.com/terraform_backend
  backend "pg" {}

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
    swarm = {
      source  = "aucloud/swarm"
      version = "1.2"
    }
  }
}

provider "swarm" {
  ssh_user = var.ssh_user
  ssh_key  = var.ssh_key
}

locals {
  // find the first manager node
  roles = {
    for node in var.cluster : node.tags.role => node
  }
  manager     = local.roles["manager"]
  docker_host = "ssh://${var.ssh_user}@${local.manager.public_address}"
}

provider "docker" {
  host     = local.docker_host
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null", "-i", var.ssh_key]
}

module "swarm" {
  source = "./module/swarm"
  nodes  = var.cluster
}

module "log" {
  source = "./module/log"

  traefik_network_id = module.swarm.network_traefik_public_id
  host_name_base     = var.host_name_base

  depends_on = [module.swarm]
}

module "router" {
  source = "./module/router"
  traefik_network = {
    name = module.swarm.network_traefik_public_name
    id   = module.swarm.network_traefik_public_id
  }

  cf_dns_api_token = var.cf_dns_api_token
  host_name_base   = var.host_name_base

  depends_on = [module.swarm]
}

# TODO loop over docker nodes
module "dockge" {
  source = "./module/dockge"

  traefik_network_id = module.swarm.network_traefik_public_id
  host_name_base     = var.host_name_base
  ssh_user           = var.ssh_user

  depends_on = [module.swarm]
}
