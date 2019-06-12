# Purpose
This tutorial aims to show you how to build a simple AWS example using
Terraform. The example I choose is
[Getting Started with IPv4 for Amazon VPC](https://docs.aws.amazon.com/vpc/latest/userguide/getting-started-ipv4.html?shortFooter=true)

# Requirements
* You must have an AWS account, if you don't already have one, you can subscribe
to the free tier
* You must install Terraform v0.12.X

# Usage
## Creating the S3 backend to store the Terraform states
If you have not already created a S3 backend, follow my first tutorial
[https://github.com/richardpct/aws-terraform-tuto01](https://github.com/richardpct/aws-terraform-tuto01)

## Setting up the required variables
Copy aws-terraform-tuto02.tfvars-sample into aws-terraform-tuto02.tfvars, then
fill the values according to your needs.

## Initializing your Terraform working directory
    $ cd aws-terraform-tuto02
    $ make init

## Creating the VPC and webserver
    $ cd aws-terraform-tuto02
    $ make apply

## Installing apache2
The previous command displays the EIP address associated with the webserver,
wait a few seconds then connect to it through SSH:

    $ ssh admin@xx.xx.xx.xx
    $ sudo -i
    $ apt-get update
    $ apt-get upgrade
    $ apt-get install -y apache2

Then open your web browser and use the IP address of your webserver

## Cleaning up
    $ cd aws-terraform-tuto02
    $ make destroy
