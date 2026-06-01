# ============================================================
# Week 1 Day 1 - Decode Access Token
# ============================================================
# Prerequisites:
#   Run request-token.ps1 first to populate $accessToken
# ============================================================

if (-not $accessToken) {
    Write-Host "No access token found. Run request-token.ps1 first." -ForegroundColor Red
    return
}

Write-Host "Decoding access token..." -ForegroundColor Cyan

$claims = Decode-JwtPayload $accessToken

Write-Host ""
Write-Host "=== Token Claims ===" -ForegroundColor Yellow
Write-Host "iss (issuer):     $($claims.iss)"
Write-Host "aud (audience):   $($claims.aud)"
Write-Host "sub (subject):    $($claims.sub)"
Write-Host "cid (client ID):  $($claims.cid)"
Write-Host "scp (scopes):     $($claims.scp)"
Write-Host "iat (issued at):  $($claims.iat)"
Write-Host "exp (expires):    $($claims.exp)"
Write-Host "jti (token ID):   $($claims.jti)"
Write-Host ""
Write-Host "=== IAM Interpretation ===" -ForegroundColor Yellow
Write-Host "Identity:         Service app (sub = cid = $($claims.cid))"
Write-Host "Permission:       $($claims.scp)"
Write-Host "Valid for:        $($claims.exp - $claims.iat) seconds"
Write-Host "Token type:       Application permission (app acting as itself)"
