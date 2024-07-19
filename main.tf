terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "docker" {
  host     = var.docker_host
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
}

module "swarm" {
  source = "./module/swarm"
}

module "log" {
  source             = "./module/log"
  traefik_network_id = module.swarm.network_traefik_public_id
}

module "router" {
  source             = "./module/router"
  traefik_network_id = module.swarm.network_traefik_public_id
  cf_dns_api_token   = var.cf_dns_api_token
}
