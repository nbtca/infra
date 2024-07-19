terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}


resource "docker_network" "traefik_public" {
  name       = "traefik-public"
  driver     = "overlay"
  internal   = false
  attachable = true
}

output "network_traefik_public_id" {
  value = docker_network.traefik_public.id
}
