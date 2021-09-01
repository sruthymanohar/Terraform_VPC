# Terraform_Vpc
[![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://travis-ci.org/joemccann/dillinger)

Here is a simple project on how to create a custom vpc with ec2 instances via terraform. In this project we are creating 3 ec2 instances in our own custom VPC. One instance for database one for webserver and another one is for bastion server. For the security purpose we are creating DB server in private network
 
## Prerequisites for this project
- Need a IAM user access with attached policies for the creation of VPC and EC2.
- Knowledge to the working principles of each AWS services especially VPC, EC2 and IP Subnetting.


## Features

- All Ec2 resource creations are done using terraform
- Each subnet CIDR block created automatically using subnetbit Function 
- AWS informations are defined using tfvars file and can easily changed 
- We can easily migrate the  infrastrucre to another region by chaging provides details.
- All the resoruce names are appended with project name so we can easily identify the -resources

## Terraform installtion 
You can easily download terraform using the following  official documentation provided by terraform.

https://www.terraform.io/downloads.html

Sample installation steps

```sh 
wget https://releases.hashicorp.com/terraform/0.15.3/terraform_0.15.3_linux_amd64.zip
unzip terraform_0.15.3_linux_amd64.zip 
ls -l
-rwxr-xr-x 1 root root 79991413 May  6 18:03 terraform  <<=======
-rw-r--r-- 1 root root 32743141 May  6 18:50 terraform_0.15.3_linux_amd64.zip
mv terraform /usr/bin/
which terraform 
/usr/bin/terraform
```

The next is configuration of AWS provider. So, we are creating a file named provider.tf for this purpose and mentioned our region name, IAM access key and seceret key in that file.

```sh 
provider "aws" {
  region     = region
  access_key = *************
  secret_key = ************
}
```
Now the next step is Initialize the working directory containing Terraform configuration files using below command.

```sh 
terraform init
```

Lets create a file for declaring the variables.The following file is used to declare the variable and the values are passed via tfvars file.

The contents of variable.tf file is pasted below :
```sh 
variable "project" {}

variable "vpc_cidr" {}

variable "subnetbit" {}
```

Now the next step is Creation  of  terraform.tfvars file. 

```sh 
project = "Blog"
vpc_cidr = "172.16.0.0/16"
subnetbit = "3"
```
You can modify the  values  of tfvars file accordingly as per your requirements. From the above HCL code you can understood that  we are creating a vpc in IP range 172.16.0.0/16 and subnet bit is 3 .

Lets start creating vpc.tf file with the details below.

```sh
###########################################################################
#Vpc Creation
###########################################################################
 
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project}-vpc"
  }
lifecycle {
    create_before_destroy = true
  }
}
```

To find all the avilabilty zone  inside the selected aws region using following code 

```sh 
###########################################################################
#List of AWS Availability Zones in this account
##########################################################################



data "aws_availability_zones" "az" {
  state = "available"
}
```
To create Internet GateWay For VPC

```sh 
###########################################################################
#Igw Creation
###########################################################################

resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project}-igw"
  }
lifecycle {
    create_before_destroy = true
  }
}
```
Here in this infrastructre we  will create 3 public and 3 private subnets .This sample was meant for regions having 6 availability zone. I have used "us-east-1". You can change the region name according to your requirement, Also, we already mentioned subnet bit in tfvars file so there is no need to calculate CIDR for subnet division .  Here the CIDR range of subnet is /19.

```sh
###########################################################################
#Subnet Creation public 1
###########################################################################

 
resource "aws_subnet" "public1" {

  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr , var.subnetbit , 0)
  availability_zone = data.aws_availability_zones.az.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project}-public1"
  }

}
```
```sh 
###########################################################################
#Subnet Creation public 2
###########################################################################

resource "aws_subnet" "public2" {

  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr , var.subnetbit , 1)
  availability_zone = data.aws_availability_zones.az.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project}-public2"
  }

}
```
```sh 
###########################################################################
#Subnet Creation public 3
###########################################################################


resource "aws_subnet" "public3" {

  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr , var.subnetbit , 2)
  availability_zone = data.aws_availability_zones.az.names[2]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project}-public3"
  }

}
```
```sh 
###########################################################################
#Subnet Creation private1
###########################################################################


resource "aws_subnet" "private1" {

  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr , var.subnetbit , 3)
  availability_zone = data.aws_availability_zones.az.names[3]
  tags = {
    Name = "${var.project}-private1"
  }

}
```
```sh 
###########################################################################
#Subnet Creation private2
###########################################################################


resource "aws_subnet" "private2" {

  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr , var.subnetbit , 4)
  availability_zone = data.aws_availability_zones.az.names[4]
  tags = {
    Name = "${var.project}-private2"
  }

}

```
```sh 
###########################################################################
#Subnet Creation private3
###########################################################################

resource "aws_subnet" "private3" {

  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr , var.subnetbit , 5)
  availability_zone = data.aws_availability_zones.az.names[5]
  tags = {
    Name = "${var.project}-private3"
  }

}
```

```sh 
###########################################################################
#Elastic Ip Creation
###########################################################################

resource "aws_eip" "eip" {

  vpc      = true
  tags     = {
    Name = "${var.project}-eip"
  }
}
```

```sh 
##########################################################################
#Allocate Elastic IP to NAT Gateway
##########################################################################


resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name = "${var.project}-NAT"
  }
}
```
Now we are creating 2 route tables one for public subnets and another one for private subnet.

```sh 
#########################################################################
#Public Route table
#########################################################################
resource "aws_route_table" "route1" {
  vpc_id = aws_vpc.main.id

  route{
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
    }

  tags = {
    Name = "route1"
  }

}
```
```sh 
###########################################################################
#Private Route table
###########################################################################


resource "aws_route_table" "route2" {
  vpc_id = aws_vpc.main.id

  route{
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.nat.id
    }

  tags = {
    Name = "route2"
  }

}
```

Now the next step is route tavle associations,

```sh
################################################################################
#Public Route table associations
################################################################################

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.route1.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.route1.id
}

resource "aws_route_table_association" "public3" {
  subnet_id      = aws_subnet.public3.id
  route_table_id = aws_route_table.route1.id
}
```
```sh
################################################################################
# Private Route table associations
################################################################################
 
resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.route2.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.route2.id
}

resource "aws_route_table_association" "private3" {
  subnet_id      = aws_subnet.private3.id
  route_table_id = aws_route_table.route2.id
}
```

Now , we have created a vpc named Blog-Vpc with 6 subnets 3 for public subnets and 3 for private subnets.

The next step is creation of 3 EC2 instances in our custom vpc "BLog-Vpc",

In EC2 launcing the initial step is  creation of key pair . Here I have used ssh-keygen for creating ssh key and uploaded it using file function in terraform.

```sh 
################################################################################
#Key Pair creation
################################################################################
resource "aws_key_pair" "key" {

  key_name   = "terraform"
  public_key = file("terraform.pub")
  tags       = {
    Name = "terraform"
  }
}

```
Now we can create 3 security group for our instances. 

```sh
###############################################################################
#Security Group-Bastion server
###############################################################################
resource "aws_security_group" "bastion" {

  name        = "bastion"
  description = "allows 22"
  vpc_id      = aws_vpc.main.id
  ingress {

    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  egress {

    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "bastion"
  }
}
```
```sh
############################################################################
#Security group webserver
############################################################################

resource "aws_security_group" "webserver" {

  name        = "webserver"
  description = "allows 22, 80.443"
  vpc_id      = aws_vpc.main.id

  ingress {

    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
 ingress {

    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {

    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  egress {

    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "webserver"
  }
}
```
```sh
#############################################################################
#Security Group -Database Server
#############################################################################

resource "aws_security_group" "database" {

  name        = "database"
  description = "allows 3306"
  vpc_id      = aws_vpc.main.id
  ingress {

    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  egress {

    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "database"
  }
}
```
```sh
############################################################################
#Ec2 instance creation -Bastion server
#############################################################################

resource "aws_instance" "Bastion-Server" {

  ami                          = "ami-0443305dabd4be2bc"
  instance_type                = "t2.micro"
  key_name                     = aws_key_pair.key.key_name
  associate_public_ip_address  =  true
  security_groups              = [aws_security_group.bastion.id]
  subnet_id                    = aws_subnet.public1.id
  tags = {
    Name = "Bastion"
  }
}
```
```sh
############################################################################
#Ec2 instance creation -webserver
############################################################################

resource "aws_instance" "weberver" {

  ami                          = "ami-0443305dabd4be2bc"
  instance_type                = "t2.micro"
  key_name                     = aws_key_pair.key.key_name
  associate_public_ip_address  =  true
  security_groups              = [aws_security_group.webserver.id]
  subnet_id                    = aws_subnet.public2.id
  tags = {
    Name = "webserver"
  }
}
```
```sh
############################################################################
#Ec2 instance creation -DBserver
############################################################################

resource "aws_instance" "dbserver" {

  ami                          = "ami-0443305dabd4be2bc"
  instance_type                = "t2.micro"
  key_name                     = aws_key_pair.key.key_name
  security_groups              = [ aws_security_group.database.id ]
  subnet_id                    = aws_subnet.private2.id
  tags = {
    Name = "dbserver"
  }
}
```
Lets validate the terraform files using

```sh
terraform validate
```

Lets plan the architecture and verify once again.

```sh
terraform plan
```
Lets apply the above architecture to the AWS.
```sh
terraform apply
```

# Conclusion

Here we  have created Aws resources using terraform without logging to  AWS console. The only details that we have is an IAM user credentails. From this project we can undestood one of the important  Iaac  tool Terraform,

⚙️ Connect with Me
 
  <a href="https://www.linkedin.com/in/sruthy-manohar-9a9b54150/">
     <p> <img align="left" alt="Abhishek's LinkedIN" width="22px" src="https://raw.githubusercontent.com/peterthehan/peterthehan/master/assets/linkedin.svg" /> </p>
   </a>       
        
