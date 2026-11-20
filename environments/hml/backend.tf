terraform {
  backend "gcs" {
    bucket = "seia-adapar-hml-tfstate-southamericaeast1"
    prefix = "terraform/state"
  }
}
