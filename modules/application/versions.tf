
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.11.0"
    }
  }

  required_version = ">= 0.15.3"
}

provider "docker" {
  host = var.host
}
