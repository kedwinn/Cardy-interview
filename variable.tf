variable "vpc_cidrblock" {
    type = string
    default = "10.0.0.0/16"
  description = "This is the main VPC"
}

variable "Privsub1_cidrblock" {
    type = string
    default = "10.0.1.0/24"
  description = "Cidr_block private subnet"
}

variable "Pubsub1_cidrblock" {
    type = string
    default = "10.0.2.0/24"
  description = "Cidr_block public subnet"
}

variable "AZ1" {
    type = string
    default = "eu-west-2a"
  description = "Availability zone 1"
}

variable "AZ2" {
     type = string
    default = "eu-west-2b"
  description = "Availability zone 2"
}

variable "instance_ami" {
     type = string
    default = "10.0.0.0/16"
  description = "This is the instance_ami for our Cardy vpc"
}

variable "instance_type" {
     type = string
    default = "t2.micro"
  description = "This is the instance_type for our Cardy vpc"
}

variable "key_name" {
     type = string
    default = "cardykey"
  description = "This is the instance_type for our Cardy vpc"
}