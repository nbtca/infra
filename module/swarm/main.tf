terraform {
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
variable "nodes" {
  description = "List of nodes"
  type = list(
    object({
      hostname        = string
      public_address  = string
      private_address = string
      tags            = map(string)
    })
  )
}



resource "swarm_cluster" "cluster" {
  skip_manager_validation = true
  dynamic "nodes" {
    for_each = var.nodes
    content {
      hostname        = nodes.value.hostname
      public_address  = nodes.value.public_address
      private_address = nodes.value.private_address
      tags            = nodes.value.tags
    }
  }
}

resource "docker_network" "traefik_public" {
  name       = "traefik-public"
  driver     = "overlay"
  internal   = false
  attachable = true
  depends_on = [swarm_cluster.cluster]
}

output "network_traefik_public_id" {
  value = docker_network.traefik_public.id
}
output "network_traefik_public_name" {
  value = docker_network.traefik_public.name
}

output "docker_host" {
  value = swarm_cluster.cluster.nodes[0].public_address
}
