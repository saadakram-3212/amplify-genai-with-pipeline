terraform {
  backend "s3" {
    bucket       = "amplify-genai-terraform-state"
    key          = "prod/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

