
variable "BACKEND_KEY" {
  type        = string
  default = "gymcoach-app-sandbox"
}

variable "BACKEND_BUCKET_NAME" {
  type        = string
  default = "gymcoach-oskar"
}

variable "primary_region" {
  type = string
  default = "eu-central-1"
}

variable "application_name" {
  type = string
  default = "gymcoach"
}
variable "environment_name" {
  type = string
  default = "sandbox"
}


variable "ecr_image_pushers" {
  type = list(string)
  default = ["gymcoach"]
}