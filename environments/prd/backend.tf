terraform {
  backend "gcs" {
    bucket = "seia-adapar-prd-tfstate-southamericaeast1"
    prefix = "terraform/state"
  }
}
