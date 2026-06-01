# ============================================================
# Week 1 Day 1 - Request Access Token
# ============================================================
# Prerequisites:
#   . .\config.ps1
#   . .\helpers.ps1
# ============================================================

Write-Host "Building JWT assertion..." -ForegroundColor Cyan

# Load private key
$jwk = Get-Content $privateKeyPath | ConvertFrom-Json
$rsa = Build-RsaFromJwk $jwk

# Calculate timestamps
$epoch = [datetime]"1970-01-01T00:00:00Z"
$now = [int]([datetime]::UtcNow - $epoch).TotalSeconds
$exp = $now + 30

Write-Host "  iat: $now"
Write-Host "  exp: $exp"

# Build signed JWT
$jwt = New-SignedJwt -clientId $clientId -audience $tokenEndpoint -kid $kid -iat $now -exp $exp -rsa $rsa

# Request token
Write-Host "Requesting token..." -ForegroundColor Cyan

$body = @{
    grant_type            = "client_credentials"
    client_id             = $clientId
    client_assertion_type = "urn:ietf:params:oauth:client-assertion-type:jwt-bearer"
    client_assertion      = $jwt
    scope                 = $defaultScope
}

try {
    $response = Invoke-RestMethod -Uri $tokenEndpoint -Method Post -Body $body -ContentType "application/x-www-form-urlencoded"
    $global:accessToken = $response.access_token
    
    Write-Host "Token received!" -ForegroundColor Green
    Write-Host "  Token type:  $($response.token_type)"
    Write-Host "  Expires in:  $($response.expires_in) seconds"
    Write-Host "  Scope:       $($response.scope)"
} catch {
    Write-Host "Token request failed:" -ForegroundColor Red
    Write-Host $_.Exception.Message
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $errorBody = $reader.ReadToEnd()
        Write-Host $errorBody
    }
}
