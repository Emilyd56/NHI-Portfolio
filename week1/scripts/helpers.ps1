# ============================================================
# Week 1 Day 1 - Helper Functions
# ============================================================
# Source this file before running scripts that need these functions:
#   . .\helpers.ps1
# ============================================================

function ConvertTo-Base64Url($text) {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($text)
    return [Convert]::ToBase64String($bytes).TrimEnd('=').Replace('+', '-').Replace('/', '_')
}

function ConvertFrom-Base64Url($base64url) {
    $base64 = $base64url.Replace('-', '+').Replace('_', '/')
    switch ($base64.Length % 4) {
        2 { $base64 += '==' }
        3 { $base64 += '=' }
    }
    return [Convert]::FromBase64String($base64)
}

function Build-RsaFromJwk($jwk) {
    $rsaParams = New-Object System.Security.Cryptography.RSAParameters
    $rsaParams.Modulus  = ConvertFrom-Base64Url $jwk.n
    $rsaParams.Exponent = ConvertFrom-Base64Url $jwk.e
    $rsaParams.D        = ConvertFrom-Base64Url $jwk.d
    $rsaParams.P        = ConvertFrom-Base64Url $jwk.p
    $rsaParams.Q        = ConvertFrom-Base64Url $jwk.q
    $rsaParams.DP       = ConvertFrom-Base64Url $jwk.dp
    $rsaParams.DQ       = ConvertFrom-Base64Url $jwk.dq
    $rsaParams.InverseQ = ConvertFrom-Base64Url $jwk.qi

    $rsa = New-Object System.Security.Cryptography.RSACryptoServiceProvider
    $rsa.ImportParameters($rsaParams)
    return $rsa
}

function New-SignedJwt($clientId, $audience, $kid, $iat, $exp, $rsa) {
    $header = @{
        alg = "RS256"
        typ = "JWT"
        kid = $kid
    } | ConvertTo-Json -Compress

    $payload = @{
        iss = $clientId
        sub = $clientId
        aud = $audience
        exp = $exp
        iat = $iat
        jti = [guid]::NewGuid().ToString()
    } | ConvertTo-Json -Compress

    $headerB64  = ConvertTo-Base64Url $header
    $payloadB64 = ConvertTo-Base64Url $payload
    $dataToSign = "$headerB64.$payloadB64"

    $signatureBytes = $rsa.SignData(
        [System.Text.Encoding]::UTF8.GetBytes($dataToSign),
        "SHA256"
    )
    $signatureB64 = [Convert]::ToBase64String($signatureBytes).TrimEnd('=').Replace('+', '-').Replace('/', '_')

    return "$dataToSign.$signatureB64"
}

function Decode-JwtPayload($jwt) {
    $parts = $jwt.Split('.')
    $payloadJson = [System.Text.Encoding]::UTF8.GetString((ConvertFrom-Base64Url $parts[1]))
    return $payloadJson | ConvertFrom-Json
}

Write-Host "Helpers loaded: ConvertTo-Base64Url, ConvertFrom-Base64Url, Build-RsaFromJwk, New-SignedJwt, Decode-JwtPayload" -ForegroundColor Green
