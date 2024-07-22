terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
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
    value = "Host(`traefik.${var.host_name_base}`)"
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
      image = "traefik:v3.1"

      env = {
        CF_DNS_API_TOKEN = var.cf_dns_api_token
      }

      args = [
        "--log.level=DEBUG",
        "--api.insecure=true",
        "--providers.docker=true",
        "--providers.docker.exposedbydefault=false",
        "--providers.swarm.endpoint=unix:///var/run/docker.sock",
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
    value = "Host(`whoami.${var.host_name_base}`)"
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

resource "docker_service" "speed_test" {
  name = "speed_test"

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.speed_test.rule"
    value = "Host(`speed_test.${var.host_name_base}`)"
  }
  labels {
    label = "traefik.http.routers.speed_test.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.speed_test.tls.certresolver"
    value = local.tls_resolver
  }
  labels {
    label = "traefik.http.services.speed_test.loadbalancer.server.port"
    value = "80"
  }

  task_spec {
    container_spec {
      image = "badapple9/speedtest-x"
      env = {
        TZ = "America/New_York"
      }
    }

    networks_advanced {
      name = var.traefik_network.id
    }
  }

  mode {
    global = true
  }
}
