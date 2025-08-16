# ##############################
# Variable
# ##############################
variable "app_name" {
  type    = string
  default = "nodejs-app"
}

variable "aws_region" {
  type = string
}

variable "image_id" {
  type = string
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "key_name" {
  description = "SSH Key Pair name"
}

variable "container_name" {
  type        = string
  description = "Container name"
  default     = "myapp"
}
