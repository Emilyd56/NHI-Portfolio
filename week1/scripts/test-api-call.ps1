# ============================================================
# Week 1 Day 1 - Test API Call
# ============================================================
# Prerequisites:
#   Run request-token.ps1 first to populate $accessToken
# ============================================================

if (-not $accessToken) {
    Write-Host "No access token found. Run request-token.ps1 first." -ForegroundColor Red
    return
}

Write-Host "Calling Okta Users API..." -ForegroundColor Cyan

$headers = @{
    Authorization = "Bearer $accessToken"
}

try {
    $response = Invoke-RestMethod -Uri "https://$oktaDomain/api/v1/users?limit=1" -Headers $headers
    
    Write-Host "API call successful!" -ForegroundColor Green
    Write-Host ""
    Write-Host "=== Response ===" -ForegroundColor Yellow
    $response | ConvertTo-Json -Depth 3
} catch {
    Write-Host "API call failed:" -ForegroundColor Red
    Write-Host $_.Exception.Message
}
