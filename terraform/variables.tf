variable "AWS_REGION" {}

variable "PATH_TO_PRIVATE_KEY" {}

variable "PATH_TO_PUBLIC_KEY" {}

variable "AMIS" {
  type = map(string)
  default = {
    us-east-1 = "ami-13be557e"
    us-west-2 = "ami-06b94666"
    eu-west-1 = "ami-844e0bf7"
  }
}

variable "PUBLIC_SUBNET1_ID" {}

variable "PUBLIC_SUBNET2_ID" {}

variable "PRIVATE_SUBNET1_ID" {}

variable "ELB_SG_ID" {}

variable "EC2_SG_ID" {}

