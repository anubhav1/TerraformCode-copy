variable "vpc_name" {
  description = "VPC name"
  type        = string
  default     = "ghost_vpc"
}

variable "vpc_cidr" {
  description = "VPC CIDR range"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az1" {
  description = "Availability Zones"
  type        = string
  default     = "eu-central-1a"
}

variable "az2" {
  description = "Availability Zones"
  type        = string
  default     = "eu-central-1b"
}
variable "az3" {
  description = "Availability Zones"
  type        = string
  default     = "us-east-1a"
}

variable "az4" {
  description = "Availability Zones"
  type        = string
  default     = "us-east-1b"
}

variable "public_subnet1_cidr" {
  description = "Public subnets where the ghost instances will be deployed"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet2_cidr" {
  description = "Public subnets where the ghost instances will be deployed"
  type        = string
  default     = "10.0.2.0/24"
}

variable "application_subnet1_cidr" {
  description = "Public subnets where the ghost instances will be deployed"
  type        = string
  default     = "10.0.3.0/24"
}

variable "application_subnet2_cidr" {
  description = "Public subnets where the ghost instances will be deployed"
  type        = string
  default     = "10.0.4.0/24"
}

variable "database_subnet1_cidr" {
  description = "Public subnets where the ghost instances will be deployed"
  type        = string
  default     = "10.0.5.0/24"
}

variable "database_subnet2_cidr" {
  description = "Public subnets where the ghost instances will be deployed"
  type        = string
  default     = "10.0.6.0/24"
}


