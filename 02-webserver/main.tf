module "webserver" {
  source = "../modules/webserver"

  region                      = "eu-west-3"
  network_remote_state_bucket = var.bucket
  network_remote_state_key    = var.key_network
  instance_type               = "t2.micro"
  image_id                    = "ami-00235772425cbf8ac" // amazon linux 2023
  ssh_public_key              = var.ssh_public_key
}
