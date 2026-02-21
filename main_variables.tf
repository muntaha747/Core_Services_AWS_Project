variable "dev_vpc" {
  description = "Name of the vpc"
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_route_table" {
  description = "Public Route Table"
  type        = string
  default     = "0.0.0.0/0"
}

variable "subnet_1" {
  description = "Public Subnet 1"
  type        = string
  default     = "10.20.1.0/24"
}

variable "subnet_2" {
  description = "Public Subnet 2"
  type        = string
  default     = "10.20.2.0/24"
}

variable "subnet_3" {
  description = "Private Subnet 3"
  type        = string
  default     = "10.20.3.0/24"
}

variable "subnet_4" {
  description = "Private Subnet 4"
  type        = string
  default     = "10.20.4.0/24"
}

variable "private_route_table" {
  description = "Private Route table"
  type        = string
  default     = "0.0.0.0/0"
}

variable "az_1a" {
  description = "Availability Zone"
  type        = string
  default     = "ca-central-1a"
}

variable "az_1b" {
  description = "Availability Zone"
  type        = string
  default     = "ca-central-1b"
}

variable "az_1d" {
  description = "Availability Zone"
  type        = string
  default     = "ca-central-1b"
}


variable "AMMID" {
  description = "Image_ID"
  type        = string
  default     = "ami-09547c8673abb0190"
}

variable "key_pair" {
  description = "Key_pair"
  type        = string
  default     = "Lamp-EC2-Key-Pair"
}



variable "EC2_type" {
  description = "EC2 Type"
  type        = string
  default     = "t3.micro"
}

variable "SSG_AWS_EC2_Firewall" {
  description = "EC2 SSG"
  type        = string
  default     = "SSG_AWS_EC2_Firewall"
}


variable "bastion_host_ingress_cidr" {
  type    = string
  default = "209.171.85.216/32"
}

# variable "acm_certificate_arn" {
#   type = string
# }

