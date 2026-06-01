# Week 1 Day 1: Okta Service App Scripts

PowerShell scripts for the OAuth `private_key_jwt` client authentication lab.

## Prerequisites

1. Okta Developer account (free tier)
2. API Service app created in Okta
3. Public/private key pair generated in Okta (not client secret)
4. `okta.users.read` scope assigned to the app
5. Private key JSON saved locally (not in this repo)

## Files

| File | Purpose |
|------|---------|
| `config.ps1` | Configuration variables (update with your values) |
| `helpers.ps1` | JWT signing and Base64Url encoding functions |
| `request-token.ps1` | Build JWT assertion and exchange for access token |
| `decode-token.ps1` | Decode access token and display claims |
| `test-api-call.ps1` | Call Okta Users API with the token |

## Usage

```powershell
# 1. Update config.ps1 with your Okta values

# 2. Source the config and helpers
. .\config.ps1
. .\helpers.ps1

# 3. Request a token
. .\request-token.ps1

# 4. Decode the token
. .\decode-token.ps1

# 5. Test an API call
. .\test-api-call.ps1
```

## Why private_key_jwt?

Okta's **Org Authorization Server** (used for Okta API scopes like `okta.users.read`) requires `private_key_jwt` authentication. Client secrets are blocked for this high-value API.

This is security by platform design:
- Asymmetric: private key never leaves your machine
- Non-replayable: JWT includes timestamps and unique ID
- Attributable: signature proves which key signed it

## Key IAM Concepts Demonstrated

| Action | IAM Meaning |
|--------|-------------|
| Create service app | Create machine identity |
| Generate key pair | Issue asymmetric credential |
| Assign scope | Define permission boundary |
| Sign JWT assertion | Prove identity cryptographically |
| Exchange for token | Obtain time-bound authorization |
| Decode token claims | Inspect identity/access evidence |
| Call API with token | Exercise granted permissions |
