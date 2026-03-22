terraform {
  backend "s3" {
    bucket = var.bucket
    key    = var.key_webserver
    region = var.region
  }
}
