variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the application (leave empty to use ALB DNS)"
  type        = string
  default     = ""
}

variable "app_route53_zone_id" {
  description = "Route53 hosted zone ID (required only if using custom domain)"
  type        = string
  default     = ""
}

variable "target_group_name" {
  description = "Name of the target group"
  type        = string
}

variable "target_group_port" {
  description = "Port for the target group"
  type        = number
}

variable "alb_security_group_name" {
  description = "Name of the ALB security group"
  type        = string
}

variable "root_redirect" {
  description = "Whether to create www redirect"
  type        = bool
  default     = false
}

variable "alb_logging_bucket_name" {
  description = "Name of S3 bucket for ALB logs"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}