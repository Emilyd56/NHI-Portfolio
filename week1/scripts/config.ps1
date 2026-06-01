# ============================================================
# Week 1 Day 1 - Configuration
# ============================================================
# Source this file before running other scripts:
#   . .\config.ps1
# ============================================================

# Okta tenant configuration - REPLACE WITH YOUR VALUES
$global:clientId      = "<YOUR_CLIENT_ID>"
$global:oktaDomain    = "<YOUR_OKTA_DOMAIN>.oktapreview.com"
$global:kid           = "<YOUR_KEY_ID>"

# Private key file path (downloaded JWK from Okta when key was generated)
$global:privateKeyPath = "$HOME\okta-keys\private-key.json"

# Token endpoint
$global:tokenEndpoint = "https://$oktaDomain/oauth2/v1/token"

# Default scope to request
$global:defaultScope = "okta.users.read"

Write-Host "Config loaded:" -ForegroundColor Green
Write-Host "  Client ID:        $clientId"
Write-Host "  Okta Domain:      $oktaDomain"
Write-Host "  Key ID:           $kid"
Write-Host "  Private key file: $privateKeyPath"
Write-Host "  Token endpoint:   $tokenEndpoint"
