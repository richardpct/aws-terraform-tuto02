terraform {
  backend "s3" {
    bucket = var.bucket
    key    = var.key_network
    region = var.region
  }
}
