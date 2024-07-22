terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

locals {
  service_name = "dockge"
  mount_path   = "/home/${var.ssh_user}/dockge"
}


resource "docker_image" "dockge" {
  name = "louislam/dockge:1"
}

resource "docker_container" "dockge" {

  image = docker_image.dockge.image_id
  name  = "dockge"

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.${local.service_name}.rule"
    value = "Host(`dockge.${var.host_name_base}`)"
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
    value = "5001"
  }

  volumes {
    container_path = "/var/run/docker.sock"
    host_path      = "/var/run/docker.sock"
  }

  volumes {
    container_path = "/app/data"
    host_path      = "${local.mount_path}/data"
  }

  # Stacks Directory
  # ⚠️ READ IT CAREFULLY. If you did it wrong, your data could end up writing into a WRONG PATH.
  # ⚠️ 1. FULL path only. No relative path (MUST)
  # ⚠️ 2. Left Stacks Path === Right Stacks Path (MUST)
  volumes {
    container_path = local.mount_path
    host_path      = local.mount_path
  }

  networks_advanced {
    name = var.traefik_network_id
  }

}
