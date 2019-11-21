variable "region" {
  description = "AWS region"
}

variable "vpc_cidr_block" {
  description = "CIDR block for main VPC"
}

variable "sn_alb_cidr_block" {
  description = "CIDR block for LB subnet"
}


variable "sn_alb2_cidr_block" {
  description = "CIDR block for LB second subnet"
}

variable "sn_web_cidr_block" {
  description = "CIDR block for application subnet"
}

variable "sn_db_cidr_block" {
  description = "CIDR block for RDS subnet"
}

variable "sn_db2_cidr_block" {
  description = "CIDR block for RDS second subnet"
}

variable "http_port" {
  description = "HTTP port"
  default     = "80"
}

variable "db_port" {
  description = "DB port"
  default     = "5432"
}

variable "db_version" {
  description = "Postgres version"
}

variable "db_instance_class" {
  description = "RDS instance class"
}

variable "ami_id" {
  description = "Image id"
}

variable "web_instance_type" {
  description = "EC2 instance type"
}

variable "asg_min_size" {
  description = "Min count of EC2 instances in WEB ASG"
}

variable "asg_max_size" {
  description = "Max count of EC2 instances in WEB ASG"
}

variable "asg_desire_capacity" {
  description = "Desire capacity of EC2 instances in WEB ASG"
}

variable "db_role" {
  description = "DB role"
}
variable "db_extension" {
  description = "Postgres extension"
}