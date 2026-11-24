terraform {
  required_version = ">= 1.6.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0"
    }
  }

  backend "gcs" {
    bucket = "seia-adapar-dev-lab-4408-tfstate"
    prefix = "terraform/state/dev"
  }
}
