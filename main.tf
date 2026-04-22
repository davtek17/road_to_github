terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

#########################
# Red Docker
#########################
resource "docker_network" "lab_network" {
  name = "terraform_lab_network"
}

#########################
# Volumen persistente
#########################
resource "docker_volume" "nginx_data" {
  name = "nginx_data"
}

#########################
# Imagen Alpine
#########################
resource "docker_image" "alpine" {
  name = "alpine:latest"
}

#########################
# Imagen Nginx
#########################
resource "docker_image" "nginx" {
  name = "nginx:latest"
}

#########################
# Contenedores Alpine
#########################
resource "docker_container" "alpine_nodes" {
  count = 4

  name  = "alpine-${count.index + 1}"
  image = docker_image.alpine.image_id

  command = ["sleep", "3600"]

  networks_advanced {
    name = docker_network.lab_network.name
  }
}

#########################
# Contenedor Nginx
#########################
resource "docker_container" "nginx" {
  name  = "nginx_lab"
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = 80
  }

  volumes {
    volume_name    = docker_volume.nginx_data.name
    container_path = "/usr/share/nginx/html"
  }

  networks_advanced {
    name = docker_network.lab_network.name
  }
}
