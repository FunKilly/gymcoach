variable "application_name" {
  type = string
  default = "gymcoach"
}
variable "environment_name" {
  type = string
  default = "sandbox"
}

variable "primary_region" {
  type = string
  default = "eu-central-1"
}

variable "ecr_image_pushers" {
  type = list(string)
  default = ["gymcoach"]
}