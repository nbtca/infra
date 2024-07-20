terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

variable "traefik_network" {
  type = object({
    name = string
    id   = string
  })
}
variable "cf_dns_api_token" {
  type = string
}

locals {
  service_name = "traefik"
  tls_resolver = "myresolver"
}

resource "docker_volume" "acme" {
  name = "acme"
}

resource "docker_service" "traefik" {
  name = local.service_name

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.docker.network"
    value = var.traefik_network.name
  }

  labels {
    label = "traefik.http.routers.${local.service_name}.rule"
    value = "Host(`traefik.swarm.nbtca.space`)"
  }
  labels {
    label = "traefik.http.routers.${local.service_name}.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.${local.service_name}.tls.certresolver"
    value = local.tls_resolver
  }
  labels {
    label = "traefik.http.services.${local.service_name}.loadbalancer.server.port"
    value = "8080"
  }

  task_spec {
    container_spec {
      image = "traefik:v2.11"

      env = {
        CF_DNS_API_TOKEN = var.cf_dns_api_token
      }

      args = [
        "--log.level=DEBUG",
        "--api.insecure=true",
        "--providers.docker=true",
        "--providers.docker.exposedbydefault=false",
        "--providers.docker.swarmmode",
        "--entryPoints.web.address=:80",
        "--entryPoints.websecure.address=:443",
        "--entryPoints.web.http.redirections.entryPoint.to=websecure",
        "--certificatesresolvers.${local.tls_resolver}.acme.storage=/mnt/acme.json",
        "--certificatesresolvers.${local.tls_resolver}.acme.email=contact@nbtca.space",
        "--certificatesresolvers.${local.tls_resolver}.acme.dnschallenge.provider=cloudflare",
      ]

      mounts {
        target    = "/var/run/docker.sock"
        source    = "/var/run/docker.sock"
        type      = "bind"
        read_only = true
      }

      mounts {
        target = "/mnt"
        source = docker_volume.acme.name
        type   = "volume"
      }
    }
    networks_advanced {
      name = var.traefik_network.id
    }

    placement {
      constraints = [
        "node.role == manager"
      ]
    }
  }

  mode {
    global = true
  }

  endpoint_spec {
    ports {
      target_port    = 80
      published_port = 80
    }
    ports {
      target_port    = 443
      published_port = 443
    }
  }

}
resource "docker_service" "whoami" {
  name = "whoami"

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.whoami.rule"
    value = "Host(`whoami.swarm.nbtca.space`)"
  }
  labels {
    label = "traefik.http.routers.whoami.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.whoami.tls.certresolver"
    value = local.tls_resolver
  }
  labels {
    label = "traefik.http.services.whoami.loadbalancer.server.port"
    value = "80"
  }

  task_spec {
    container_spec {
      image = "traefik/whoami"
    }

    networks_advanced {
      name = var.traefik_network.id
    }

    placement {
      constraints = [
        "node.role == manager"
      ]
    }
  }

  mode {
    global = true
  }

}
