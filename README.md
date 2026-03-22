## Purpose

This tutorial takes up the previous one in improving our code by using the
modules. A module in OpenTofu acts like a funtion in a programming language,
and like a function we can provide some parameters.<br />
It is a good practice to work with, and you know the famous adage in computer 
science? "Don't repeat yourself!".<br />

The source code is available on my [Github repository](https://github.com/richardpct/aws-terraform-tuto02).

## Create modules in OpenTofu

Here is the new layout of our OpenTofu files located in our file system:

```
.
├── 01-network
│   ├── backends.tf
│   ├── main.tf
│   ├── Makefile
│   ├── outputs.tf
│   ├── variables.tf
│   └── versions.tf
├── 02-webserver
│   ├── backends.tf
│   ├── main.tf
│   ├── Makefile
│   ├── outputs.tf
│   ├── variables.tf
│   └── versions.tf
└── modules
    ├── network
    │   ├── main.tf
    │   ├── outputs.tf
    │   ├── providers.tf
    │   └── variables.tf
    └── webserver
        ├── outputs.tf
        ├── main.tf
        ├── providers.tf
        └── variables.tf
```

The modules are located in the modules directory, they are written as a regular
OpenTofu code.<br />
`01-network` and `02-webserver` are the modules caller, `01-network` calling
the network module with some parameters and `02-webserver` calling the
webserver module with some parameters.<br />

Let's see how to call a module with some parameters:

#### 01-network/main.tf

```
module "network" {
  source = "../modules/network"

  region         = "eu-west-3"
  vpc_cidr_block = "10.0.0.0/16"
  subnet_public  = "10.0.0.0/24"
}
```

#### 02-webserver/main.tf
```
module "webserver" {
  source = "../modules/webserver"

  region                      = "eu-west-3"
  network_remote_state_bucket = var.bucket
  network_remote_state_key    = var.key_network
  instance_type               = "t2.micro"
  image_id                    = "ami-00235772425cbf8ac" // amazon linux 2023
  ssh_public_key              = var.ssh_public_key
}
```

You have just set the `source` variable with the path of your module, then set
the values of some variables.

## Deploy your infrastructure

#### Prepare your variables

Create a file at ~/terraform/aws-terraform-tuto02/terraform_vars_secrets with the following content:<br />

```
export TF_VAR_region="eu-west-3"
export TF_VAR_bucket="XXXX-tofu-state"
export TF_VAR_key_network="tuto-02/dev/network/terraform.tfstate"
export TF_VAR_key_webserver="tuto-02/dev/webserver/terraform.tfstate"
export TF_VAR_ssh_public_key="ssh-ed25519 AAAAXXXX "
```

#### Deploy

    $ cd 01-network
    $ make apply
    $ cd ../02-webserver
    $ make apply

Install Nginx:

    $ ssh ec2-user@xx.xx.xx.xx
    $ sudo su -
    # yum update
    # yum install nginx
    # systemctl start nginx

Test:

    $ curl http://xx.xx.xx.xx

#### Clean up

    $ cd ../02-webserver
    $ make destroy
    $ cd ../01-network
    $ make destroy

## Summary

The modules are easy to write and use, so use it for avoiding to duplicate your
code.<br />
In the next tutorial I will show you how to split your code for deploying your
infrastructure in multiple environment: (dev, staging, prod ...) using the
modules.
