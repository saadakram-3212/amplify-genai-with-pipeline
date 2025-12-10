# Cognito User Pool
resource "aws_cognito_user_pool" "main" {
  name = var.userpool_name

  # Password policy
  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  # Auto-verified attributes
  auto_verified_attributes = ["email"]

  # User attributes
  schema {
    attribute_data_type      = "String"
    name                     = "email"
    required                 = true
    mutable                  = true
    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  # MFA configuration
  mfa_configuration = "OPTIONAL"
  
  software_token_mfa_configuration {
    enabled = true
  }

  # Account recovery
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  # Email configuration
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  # Lambda triggers
  dynamic "lambda_config" {
    for_each = var.create_pre_auth_lambda ? [1] : []
    content {
      pre_authentication = aws_lambda_function.pre_auth[0].arn
    }
  }

  tags = {
    Name = var.userpool_name
  }
}

# Cognito User Pool Domain - Use managed domain if no custom domain provided
resource "aws_cognito_user_pool_domain" "main" {
  domain          = var.cognito_domain != "" ? lower(replace(var.cognito_domain, "/^https?:\\/\\//", "")) : lower("${replace(var.userpool_name, "_", "-")}-${random_string.cognito_suffix.result}")
  certificate_arn = var.cognito_domain != "" && var.ssl_certificate_arn != "" ? var.ssl_certificate_arn : null
  user_pool_id    = aws_cognito_user_pool.main.id
}

# Random suffix for Cognito domain if no custom domain
resource "random_string" "cognito_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Route53 record for custom Cognito domain - Only if custom domain provided
resource "aws_route53_record" "cognito_domain" {
  count   = var.cognito_domain != "" && var.cognito_route53_zone_id != "" ? 1 : 0
  zone_id = var.cognito_route53_zone_id
  name    = var.cognito_domain
  type    = "A"

  alias {
    name                   = aws_cognito_user_pool_domain.main.cloudfront_distribution_arn
    zone_id                = "Z2FDTNDATAQYW2" # CloudFront zone ID
    evaluate_target_health = false
  }
}

# SAML Identity Provider - Only if SAML is enabled
resource "aws_cognito_identity_provider" "saml" {
  count         = var.use_saml_idp ? 1 : 0
  user_pool_id  = aws_cognito_user_pool.main.id
  provider_name = var.provider_name
  provider_type = "SAML"

  provider_details = {
    MetadataURL = var.sp_metadata_url
  }

  attribute_mapping = {
    email = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
    name  = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
  }
}

# Cognito User Pool Client
resource "aws_cognito_user_pool_client" "main" {
  name         = "${var.userpool_name}-client"
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret = true

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]

  callback_urls = var.callback_urls
  logout_urls   = var.logout_urls

  supported_identity_providers = var.use_saml_idp ? [
    "COGNITO",
    aws_cognito_identity_provider.saml[0].provider_name
  ] : ["COGNITO"]

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]

  # Token validity
  access_token_validity  = 60
  id_token_validity      = 60
  refresh_token_validity = 30

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  prevent_user_existence_errors = "ENABLED"

  depends_on = [aws_cognito_identity_provider.saml]
}