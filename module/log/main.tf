terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

variable "traefik_network_id" {
  type = string
}

locals {
  service_name   = "log"
}

resource "docker_service" "log" {

  name = "dozzle"

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.${local.service_name}.rule"
    value = "Host(`log.swarm.nbtca.space`)"
  }
  labels {
    label = "traefik.http.routers.${local.service_name}.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.${local.service_name}.tls.certresolver"
    value = "myresolver"
  }
  labels {
    label = "traefik.http.services.${local.service_name}.loadbalancer.server.port"
    value = "8080"
  }

  task_spec {

    container_spec {
      image = "amir20/dozzle:latest"

      env = {
        DOZZLE_MODE = "swarm"
      }

      mounts {
        target = "/var/run/docker.sock"
        source = "/var/run/docker.sock"
        type   = "bind"
      }

    }
    networks_advanced {
      name = var.traefik_network_id
    }

  }

  mode {
    global = true
  }
}
