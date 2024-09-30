data "terraform_remote_state" "gymcoach_state" {
  backend = "s3"
  config = {
    bucket = var.BACKEND_BUCKET_NAME
    key    = var.BACKEND_KEY
    region = "eu-central-1"
  }
}
