# Purpose
This example takes up my first tutorial
[https://github.com/richardpct/aws-terraform-tuto01](https://github.com/richardpct/aws-terraform-tuto01)
by using the modules feature.

# Requirement
* You must have an AWS account, if you don't have yet, you can subscribe to the free tier.
* You must install terraform

# Usage
## Exporting the required variables in your terminal:
    $ export TF_VAR_region="eu-west-3"
    $ export TF_VAR_bucket="mybucket-terraform-state"
    $ export TF_VAR_dev_network_key="terraform/dev/network/terraform.tfstate"
    $ export TF_VAR_dev_webserver_key="terraform/dev/webserver/terraform.tfstate"
    $ export TF_VAR_ssh_public_key="ssh-rsa ..."

## Creating the S3 backend to store the terraform state
If you have not created a S3 backend, see my first tutorial
[https://github.com/richardpct/aws-terraform-tuto01](https://github.com/richardpct/aws-terraform-tuto01)

## Creating the VPC
    $ cd 01-network
    $ ./terraform_init.sh (execute this command once)
    $ terraform apply

## Creating the webserver
    $ cd ../02-webserver
    $ ./terraform_init.sh (execute this command once)
    $ terraform apply

## Installing apache2
The last command displays the IP address of your webserver, wait a few seconds then connect to it via ssh:

    $ ssh admin@xx.xx.xx.xx
    $ sudo su -
    $ apt-get update
    $ apt-get upgrade
    $ apt-get install apache2

Then open your web browser with the IP address of your webserver

## Cleaning up
    $ cd ../02-webserver
    $ terraform destroy
    $ cd ../01-network
    $ terraform destroy
