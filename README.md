# Purpose
This example takes up [my first tutorial](https://github.com/richardpct/aws-terraform-tuto01) by using modules feature.

# Requirement
* You must have an aws account, if you don't have yet, you can subscribe the free tier.
* You must install terraform

# Usage
## Exporting the required variables from your terminal:
    $ export TF_VAR_region="eu-west-3"
    $ export TF_VAR_bucket="example-terraform-state"
    $ export TF_VAR_dev_network_key="example/env/network/terraform.tfstate"
    $ export TF_VAR_dev_webserver_key="example/env/webserver/terraform.tfstate"
    $ export TF_VAR_ssh_public_key="ssh-rsa ..."

## Creating the s3 backend to store the terraform state
    $ cd 00-bucket
    $ terraform init
    $ terraform apply

## Creating the VPC
    $ cd ../01-network
    $ ./terraform_init.sh (execute this command once)
    $ terraform apply

## Creating the webserver
    $ cd ../02-webserver
    $ ./terraform_init.sh (execute this command once)
    $ terraform apply

## Installing apache2
The last command displays the address IP of your webserver, wait a few seconds then connect to it via ssh:

    $ ssh admin@xx.xx.xx.xx
    $ sudo su -
    $ apt-get update
    $ apt-get upgrade
    $ apt-get install apache2

Then open your web browser with the webserver IP address.

## Destroying all resources you have just created
    $ cd ../02-webserver
    $ terraform destroy
    $ cd ../01-network
    $ terraform destroy
