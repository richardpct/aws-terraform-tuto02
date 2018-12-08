terraform {
  backend "s3" {}
}

module "webserver" {
  source = "../modules/webserver"

  region                      = "eu-west-3"
  network_remote_state_bucket = "${var.bucket}"
  network_remote_state_key    = "${var.dev_network_key}"
  instance_type               = "t2.micro"
  image_id                    = "ami-00000f9d1b75a36f8"
  ssh_public_key              = "${var.ssh_public_key}"
}
