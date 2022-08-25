provider "auth0" {
  domain        = var.auth0_domain
  client_id     = var.auth0_client_id
  client_secret = var.auth0_client_secret
}

resource "auth0_client" "web_monitor_client" {
  name                = "Web Monitor - Frontend"
  description         = "Web Monitor - Frontend React Application"
  app_type            = "spa"
  callbacks           = ["http://localhost:4200"]
  allowed_logout_urls = ["http://localhost:4200"]
  web_origins         = ["http://localhost:4200"]
  oidc_conformant     = true
  token_endpoint_auth_method = "none"
  grant_types = [
    "authorization_code",
    "implicit",
    "refresh_token"
  ]

  jwt_configuration {
    alg = "RS256"
  }
}

resource "auth0_resource_server" "web_monitor_resource_server" {
  name            = "Web Monitor - API"
  identifier       = "https://aws.amazon.com/"
  signing_alg     = "RS256"
  token_lifetime  = 8600
}

resource "auth0_user" "admin_user" {
  connection_name = "Username-Password-Authentication"
  name            = "Mateusz Jonak"
  email           = "mateusz.jonak@gmail.com"
  email_verified   = true
  password        = var.auth0_admin_password
  roles           = [auth0_role.admin.id]
}

resource "auth0_role" "admin" {
  name        = "admin"
  description = "Administrator"
}