# Week 3, Day 1: What Scopes Are and Why They Matter for Machine Identities

**Date**: June 5, 2026  
**Quiz Score**: 5/5

---

## 1. Core Idea

A **scope** is a permission boundary. It defines WHAT an identity is allowed to do.

Think of scopes like a checklist at a security checkpoint:
- Can enter the building? ✓
- Can access the server room? ✗
- Can read the files? ✓
- Can delete the files? ✗

Scopes are that checklist - explicitly written into the token.

---

## 2. Concept Breakdown

### What a Scope Actually Is

A scope is a **string** that represents a permission. Examples:

| Scope | What It Means |
|-------|---------------|
| `okta.users.read` | Read user data in Okta |
| `okta.users.manage` | Read AND write user data in Okta |
| `repo` | Full access to GitHub repositories |
| `read:packages` | Read-only access to GitHub packages |
| `Mail.Read` | Read emails in Microsoft Graph |
| `Mail.Send` | Send emails in Microsoft Graph |

The scope is just a string. Its meaning comes from what the **resource server** does when it sees that string.

### The Three Parties in Scope Decisions

| Party | Role in Scopes |
|-------|----------------|
| **Authorization Server** | Defines what scopes exist; issues tokens with scopes |
| **Client** | Requests specific scopes |
| **Resource Server** | Enforces scopes - rejects calls that require scopes the token doesn't have |

The authorization server doesn't enforce scopes - it just puts them in the token. The resource server reads the token and decides: "Does this token have the scope I require for this operation?"

### How Scopes Get Into a Token

1. **Client requests scopes** in the token request
2. **Authorization server checks**: Is this client allowed to request these scopes?
3. **Authorization server issues token** with the granted scopes in the `scp` claim

If the client requests scopes it's not allowed to have, the authorization server either:
- Rejects the request (`invalid_scope` error)
- Issues a token with only the allowed subset (depends on configuration)

### Scopes Are Additive, Not Hierarchical

Important: `okta.users.manage` does NOT automatically include `okta.users.read`.

If you need both read and write, you request BOTH scopes:
```
scope=okta.users.read okta.users.manage
```

This is different from some systems where "admin" implies "user" access. In OAuth, scopes are explicit - you get exactly what you ask for, nothing more.

---

## 3. Hands-On Lab: Proving Scope Enforcement

### Prerequisites

You need the Week 1 scripts loaded:
```powershell
cd "$HOME\OneDrive\Desktop\NHI Era\scripts\week1-day1"
. .\config.ps1
. .\helpers.ps1
```

### Issue: Timestamp Expiration

**Problem**: The `config.ps1` stores a `lastWorkingNow` timestamp that becomes stale after a few days due to clock skew between your system and Okta's internal clock.

**Error you'll see**:
```
{"error":"invalid_client","error_description":"The client_assertion token is expired."}
```

**Solution**: Fetch Okta's current time and use it directly:

```powershell
# Get Okta's current time from HTTP Date header
$response = Invoke-WebRequest -Uri "https://$oktaDomain" -Method HEAD -UseBasicParsing
$oktaTime = [int]([datetime]::Parse($response.Headers["Date"]).ToUniversalTime() - [datetime]"1970-01-01").TotalSeconds
Write-Host "Okta time: $oktaTime"
```

### Step 1: Request a Fresh Token (All-in-One)

Run this entire block to get a token using Okta's current time:

```powershell
$response = Invoke-WebRequest -Uri "https://$oktaDomain" -Method HEAD -UseBasicParsing
$oktaTime = [int]([datetime]::Parse($response.Headers["Date"]).ToUniversalTime() - [datetime]"1970-01-01").TotalSeconds
$jwt = New-SignedJwt -clientId $clientId -audience $tokenEndpoint -kid $kid -iat $oktaTime -exp ($oktaTime + 300) -rsa $rsa
$body = "grant_type=client_credentials&client_id=$clientId&client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer&client_assertion=$jwt&scope=$defaultScope"
$token = (Invoke-RestMethod -Uri $tokenEndpoint -Method POST -ContentType "application/x-www-form-urlencoded" -Body $body).access_token
Write-Host "Token length: $($token.Length)"
Write-Host $token
```

**Expected output**:
```
Token length: 856
eyJraWQiOiI5UDBscTRzVHlzU3A5R2xZc0tvY3BtVW9YdXZWcUhrQnRMa051R1ZpSFQ4...
```

### Step 2: Decode the Token

Go to [jwt.io](https://jwt.io) and paste the token, or decode locally:

```powershell
$payload = $token.Split(".")[1]
$padding = 4 - ($payload.Length % 4)
if ($padding -ne 4) { $payload += "=" * $padding }
[System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($payload.Replace("-","+").Replace("_","/")))
```

**Expected output** (formatted):
```json
{
  "ver": 1,
  "jti": "AT.1N0hpj1KFzioSm4Tk9WmzfNPFC5yrkF17nodcQXrui4",
  "iss": "https://org1-pro-7fe0e.oktapreview.com",
  "aud": "https://org1-pro-7fe0e.oktapreview.com",
  "sub": "0oady8o80iaVwAD1x0x7",
  "iat": 1780690264,
  "exp": 1780693864,
  "cid": "0oady8o80iaVwAD1x0x7",
  "scp": [
    "okta.users.read"
  ]
}
```

**Key observation**: The `scp` claim shows `["okta.users.read"]` - this is the scope boundary.

### Step 3: Test Scope Enforcement - CREATE User (Should Fail)

Try to create a user (requires `okta.users.manage`, which we don't have):

```powershell
$body = @{
    profile = @{
        firstName = "Test"
        lastName = "ScopeTest"
        email = "scopetest@example.com"
        login = "scopetest@example.com"
    }
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri "https://$oktaDomain/api/v1/users?activate=false" -Method POST -Headers @{Authorization = "Bearer $token"; "Content-Type" = "application/json"} -Body $body
} catch {
    Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
    $reader.ReadToEnd()
}
```

**Expected output**:
```
Status: Forbidden
```

**Why it failed**: The token was valid (correct signature, not expired), but the scope `okta.users.read` doesn't allow POST operations on users. The resource server (Okta API) enforced the scope boundary.

### Step 4: Test Scope Enforcement - READ Users (Should Succeed)

Try to read users (allowed by `okta.users.read`):

```powershell
Invoke-RestMethod -Uri "https://$oktaDomain/api/v1/users?limit=1" -Method GET -Headers @{Authorization = "Bearer $token"} | ConvertTo-Json -Depth 5
```

**Expected output**:
```json
{
    "value":  [],
    "Count":  0
}
```

**Why it succeeded**: The scope `okta.users.read` allows GET operations. The empty array just means no users exist in this tenant - but the request was authorized.

### Lab Results Summary

| Operation | Scope Needed | Your Scope | Result |
|-----------|--------------|------------|--------|
| POST /users (create) | `okta.users.manage` | `okta.users.read` | **403 Forbidden** |
| GET /users (read) | `okta.users.read` | `okta.users.read` | **200 OK** |

---

## 4. Vendor-Neutral Pattern

The portable concept is: **permission strings embedded in tokens, enforced by resource servers**.

Every authorization system has this pattern, even if they don't use the word "scope":

| System | What They Call It | Example |
|--------|-------------------|---------|
| OAuth/OIDC | Scopes | `okta.users.read` |
| AWS IAM | Actions | `s3:GetObject`, `ec2:StartInstances` |
| Azure Graph | Permissions | `User.Read`, `Mail.Send` |
| GitHub PATs | Scopes | `repo`, `workflow`, `read:org` |
| Kubernetes | Verbs | `get`, `list`, `create`, `delete` |
| MCP | Tool names | `read_file`, `write_file`, `execute_sql` |

---

## 5. Outside-Okta Mapping

### AWS IAM Policy Actions
```json
{
  "Effect": "Allow",
  "Action": [
    "s3:GetObject",
    "s3:ListBucket"
  ],
  "Resource": "arn:aws:s3:::my-bucket/*"
}
```
Same concept: identity can read from S3, but not write or delete.

### Microsoft Entra / Graph API
- `User.Read` - Read the signed-in user's profile
- `User.Read.All` - Read all users' profiles
- `Mail.Send` - Send mail as the user

### GitHub Personal Access Tokens
When you create a PAT, you check boxes for scopes:
- `repo` - Full control of private repositories
- `read:org` - Read organization membership
- `workflow` - Update GitHub Actions workflows

### MCP Tools
Each tool is essentially a scope:
- `read_file` - Can read files
- `write_file` - Can write files
- `execute_sql` - Can run database queries

---

## 6. IAM Meaning

### Scopes Implement Least-Privilege

The principle of least-privilege says: give an identity only the permissions it needs, nothing more.

Scopes are how you implement this for NHIs:
- Need to read users? Grant `okta.users.read`, not `okta.users.manage`
- Need to list repos? Grant `read:org`, not full `admin:org`

### Scopes Limit Blast Radius

| If Token Stolen With... | Attacker Can... |
|------------------------|-----------------|
| `okta.users.read` | Read all users (bad) |
| `okta.users.manage` | Read, create, modify, delete users (worse) |
| `okta.apps.manage` | Create backdoor apps, modify authentication (catastrophic) |

### Over-Scoping Is a Governance Failure

Over-scoping happens when:
- Someone requests `manage` when they only need `read`
- Someone requests broad scopes "just in case"
- Someone copies scope configuration from another app without reviewing

---

## 7. Failure Modes

### Failure Mode 1: Requesting Too Many Scopes
Client requests more than needed, increasing blast radius if token is stolen.

### Failure Mode 2: Not Enforcing Scopes at the Resource Server
Resource server ignores the scope claim - scopes become meaningless.

### Failure Mode 3: Confusing Scope with Audience
- **Scope** = WHAT you can do
- **Audience** = WHERE you can do it

A token with `okta.users.read` for one tenant can't be used at another tenant.

---

## 8. Practice Questions (with Answers)

**Q1**: A token has the scope `okta.users.read`. What happens when the client tries to delete a user?

**A1**: The request is denied due to insufficient scope. Delete requires `okta.users.manage`.

**Q2**: Who enforces scopes?

**A2**: The resource server. The client requests scope, the authorization server issues scope, and the resource server enforces it.

**Q3**: A service app requests scope `okta.users.manage` but is only configured for `okta.users.read`. What happens?

**A3**: The token request fails or returns only the allowed scope (`okta.users.read`).

**Q4**: Why does over-scoping increase risk?

**A4**: If the token is stolen, the attacker can do more damage. More scopes = larger blast radius.

**Q5**: In OAuth, if you need both read and write access, what must you do?

**A5**: Request both scopes explicitly. Scopes are additive, not hierarchical.

---

## 9. Troubleshooting Reference

### Error: "The client_assertion token is expired"
**Cause**: Clock skew between your system and Okta's internal clock.
**Fix**: Fetch Okta's time directly and use it for JWT timestamps:
```powershell
$response = Invoke-WebRequest -Uri "https://$oktaDomain" -Method HEAD -UseBasicParsing
$oktaTime = [int]([datetime]::Parse($response.Headers["Date"]).ToUniversalTime() - [datetime]"1970-01-01").TotalSeconds
```

### Error: 403 Forbidden on API call
**Cause**: Token doesn't have the required scope for the operation.
**Fix**: Check the `scp` claim in your token vs what the API endpoint requires.

### PowerShell Security Warning on Invoke-WebRequest
**Fix**: Add `-UseBasicParsing` flag.

---

## 10. Portfolio Seed

> "Scopes define what an NHI can do - they're permission boundaries embedded in tokens. The client requests scopes, the authorization server issues them, and the resource server enforces them. Over-scoping increases blast radius because if a token is stolen, the attacker gets all the permissions the token has. That's why least-privilege matters: request only what you need."

---

## Key Takeaways

1. **Scopes are permission strings** in tokens that define WHAT the identity can do
2. **Three parties**: Client requests → Authorization Server issues → Resource Server enforces
3. **Scopes are additive**, not hierarchical - request everything you need explicitly
4. **Over-scoping = governance failure** - increases blast radius on compromise
5. **The pattern is universal** - AWS Actions, Azure Permissions, GitHub scopes, MCP tools all do the same thing
