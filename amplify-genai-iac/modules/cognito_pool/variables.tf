variable "userpool_name" {
  description = "Name of the Cognito User Pool"
  type        = string
}

variable "cognito_domain" {
  description = "Custom domain for Cognito (leave empty to use managed domain)"
  type        = string
  default     = ""
}

variable "cognito_route53_zone_id" {
  description = "Route53 hosted zone ID for custom Cognito domain"
  type        = string
  default     = ""
}

variable "ssl_certificate_arn" {
  description = "ARN of SSL certificate for custom domain"
  type        = string
  default     = ""
}

variable "callback_urls" {
  description = "List of allowed callback URLs"
  type        = list(string)
}

variable "logout_urls" {
  description = "List of allowed logout URLs"
  type        = list(string)
}

variable "provider_name" {
  description = "Name of the SAML provider"
  type        = string
}

variable "sp_metadata_url" {
  description = "SAML metadata URL"
  type        = string
  default     = ""
}

variable "use_saml_idp" {
  description = "Whether to use SAML identity provider"
  type        = bool
  default     = false
}

variable "create_pre_auth_lambda" {
  description = "Whether to create pre-authentication Lambda"
  type        = bool
  default     = false
}

variable "disable_public_signup" {
  description = "Whether to disable public signup"
  type        = bool
  default     = true
}

variable "domain_name" {
  description = "Application domain name"
  type        = string
  default     = ""
}