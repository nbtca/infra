terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

module "swarm" {
  source = "./module/swarm"
}

provider "docker" {
  host     = var.docker_host
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
}


module "log" {
  source             = "./module/log"
  traefik_network_id = module.swarm.network_traefik_public_id
  depends_on         = [module.swarm]
}

module "router" {
  source = "./module/router"
  traefik_network = {
    name = module.swarm.network_traefik_public_id
    id   = module.swarm.network_traefik_public_name
  }
  cf_dns_api_token = var.cf_dns_api_token
  depends_on       = [module.swarm]
}
