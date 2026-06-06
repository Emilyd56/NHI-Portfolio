# Week 3, Day 2: Okta Management Scopes - Read vs Manage

**Date**: June 6, 2026  
**Quiz Score**: 5/5

---

## 1. Core Idea

Okta organizes its API scopes into a predictable pattern: **read** vs **manage**.

- `okta.users.read` → can GET users
- `okta.users.manage` → can GET, POST, PUT, DELETE users

This pattern applies across Okta resources: users, groups, apps, policies, logs.

---

## 2. Concept Breakdown

### The Okta Scope Pattern

```
okta.<resource>.<permission>
```

| Permission | HTTP Methods Allowed |
|------------|---------------------|
| `read` | GET only |
| `manage` | GET, POST, PUT, DELETE |

**Important**: `manage` includes read capability. But `read` does NOT include manage.

### Okta's Dual Authorization Model

**Key Discovery**: In Okta, service apps need BOTH:
1. **OAuth Scope** - controls what the TOKEN can request
2. **Admin Role** - controls what the SERVICE APP can do

| Layer | What It Controls | Where Configured |
|-------|------------------|------------------|
| OAuth Scope | What the token can request | App → Okta API Scopes |
| Admin Role | What the service app can do | App → Admin Roles |

Both must permit the operation, or it fails.

---

## 3. Hands-On Lab: Read vs Manage Scope Enforcement

### Prerequisites

Load the Week 1 scripts:
```powershell
cd "$HOME\OneDrive\Desktop\NHI Era\scripts\week1-day1"
. .\config.ps1
. .\helpers.ps1
$jwk = Get-Content $privateKeyPath -Raw | ConvertFrom-Json
$rsa = Build-RsaFromJwk $jwk
```

### Step 1: Grant Manage Scope in Okta Admin Console

1. Go to `https://org1-pro-7fe0e.oktapreview.com/admin`
2. **Applications** → **Applications** → Select your service app
3. Click **Okta API Scopes** tab
4. Find `okta.users.manage` → Click **Grant**

### Step 2: Assign an Admin Role

1. In the same app, click **Admin roles** tab
2. Click **Edit assignments**
3. Assign **Organization Administrator** role
4. Save

**Note**: Help Desk Administrator with limited resources won't work - the role must cover the users you want to manage.

### Step 3: Create a Test User in Okta

1. **Directory** → **People** → **Add Person**
2. Fill in name, email, password
3. Save and note the User ID from the URL (starts with `00u`)

### Step 4: Get a Manage Token

```powershell
$response = Invoke-WebRequest -Uri "https://$oktaDomain" -Method HEAD -UseBasicParsing
$oktaTime = [int]([datetime]::Parse($response.Headers["Date"]).ToUniversalTime() - [datetime]"1970-01-01").TotalSeconds
$jwt = New-SignedJwt -clientId $clientId -audience $tokenEndpoint -kid $kid -iat $oktaTime -exp ($oktaTime + 300) -rsa $rsa
$manageBody = "grant_type=client_credentials&client_id=$clientId&client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer&client_assertion=$jwt&scope=okta.users.manage"
$manageToken = (Invoke-RestMethod -Uri $tokenEndpoint -Method POST -ContentType "application/x-www-form-urlencoded" -Body $manageBody).access_token
Write-Host "Manage token: $($manageToken.Length) chars"
```

### Step 5: Update User with Manage Token

```powershell
$userId = "YOUR_USER_ID_HERE"
$updateBody = @{ profile = @{ nickName = "ManageWorks" } } | ConvertTo-Json

try {
    $result = Invoke-RestMethod -Uri "https://$oktaDomain/api/v1/users/$userId" -Method POST -Headers @{Authorization = "Bearer $manageToken"; "Content-Type" = "application/json"} -Body $updateBody
    Write-Host "Update succeeded!" -ForegroundColor Green
    Write-Host "Nickname set to: $($result.profile.nickName)"
} catch {
    Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
}
```

**Expected output**:
```
Update succeeded!
Nickname set to: ManageWorks
```

### Step 6: Prove Read Token Can't Modify

```powershell
$response = Invoke-WebRequest -Uri "https://$oktaDomain" -Method HEAD -UseBasicParsing
$oktaTime = [int]([datetime]::Parse($response.Headers["Date"]).ToUniversalTime() - [datetime]"1970-01-01").TotalSeconds
$jwt = New-SignedJwt -clientId $clientId -audience $tokenEndpoint -kid $kid -iat $oktaTime -exp ($oktaTime + 300) -rsa $rsa
$readBody = "grant_type=client_credentials&client_id=$clientId&client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer&client_assertion=$jwt&scope=okta.users.read"
$readToken = (Invoke-RestMethod -Uri $tokenEndpoint -Method POST -ContentType "application/x-www-form-urlencoded" -Body $readBody).access_token

$updateBody = @{ profile = @{ nickName = "ReadAttempt" } } | ConvertTo-Json

try {
    Invoke-RestMethod -Uri "https://$oktaDomain/api/v1/users/$userId" -Method POST -Headers @{Authorization = "Bearer $readToken"; "Content-Type" = "application/json"} -Body $updateBody
    Write-Host "Update succeeded" -ForegroundColor Green
} catch {
    Write-Host "Read token blocked: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
}
```

**Expected output**:
```
Read token blocked: Forbidden
```

### Step 7: Cleanup - Revoke Manage Scope

1. Go to Okta Admin Console
2. **Applications** → your app → **Okta API Scopes**
3. Click **Revoke** next to `okta.users.manage`

### Lab Results Summary

| Token Scope | Admin Role | Update User | Result |
|-------------|------------|-------------|--------|
| `okta.users.read` | Org Admin | Attempted | **403 Forbidden** |
| `okta.users.manage` | None | Attempted | **403 Forbidden** |
| `okta.users.manage` | Help Desk (limited) | Attempted | **403 Forbidden** |
| `okta.users.manage` | Org Admin | Attempted | **200 OK** |

---

## 4. Troubleshooting Reference

### Error: 403 Forbidden with manage scope

**Possible causes**:
1. Admin role not assigned to service app
2. Admin role is scoped to limited resources (not covering the target user)
3. Token expired - get a fresh one

**Fix**: Check App → Admin roles tab, ensure role covers all users.

### RSA key null error

**Cause**: Private key not loaded before signing JWT.

**Fix**:
```powershell
$jwk = Get-Content $privateKeyPath -Raw | ConvertFrom-Json
$rsa = Build-RsaFromJwk $jwk
```

---

## 5. Vendor-Neutral Pattern

Most platforms have layered authorization:

| Platform | Layer 1 | Layer 2 |
|----------|---------|---------|
| Okta | OAuth Scope | Admin Role |
| AWS | IAM Policy | Resource Policy |
| Azure | Graph Permissions | Role Assignment |
| GitHub | Token Scopes | Repository Permissions |

This is defense in depth - multiple gates must open for access.

---

## 6. Practice Questions (with Answers)

**Q1**: What's the difference between `okta.users.read` and `okta.users.manage`?

**A1**: `okta.users.read` is GET only - read, list, view users. `okta.users.manage` includes GET, POST, PUT, DELETE - full create, read, update, delete capabilities.

**Q2**: Why did our update fail when we had `okta.users.manage` scope but only Help Desk Admin role with limited resources?

**A2**: Okta requires BOTH the OAuth scope AND an admin role with broad enough permissions. The Help Desk Admin role was scoped to a limited resource set that didn't include the test user.

**Q3**: A reporting dashboard needs to display user counts and names. What scope should it have?

**A3**: `okta.users.read` - a reporting dashboard only needs to display data, not create, update, or delete users.

**Q4**: What two things does an Okta service app need to perform write operations via the API?

**A4**: OAuth scope (like `okta.users.manage`) AND an admin role (like Organization Administrator).

**Q5**: After finishing a task that required `manage` scope, what should you do and why?

**A5**: Revoke the manage scope to return to least-privilege. If the token leaked, an attacker would have create, update, or delete access for the token's lifetime.

---

## 7. Key Takeaways

1. **Read vs Manage**: `read` = GET only, `manage` = full CRUD
2. **Dual authorization**: Okta requires BOTH OAuth scope AND admin role for write operations
3. **Admin role scope matters**: A role limited to certain resources won't work for users outside that scope
4. **Cleanup after elevated access**: Revoke manage scope when done - least-privilege
5. **Defense in depth**: Multiple authorization layers must all permit the action

---

## 8. Portfolio Seed

> "Okta service apps need both OAuth scopes AND admin roles to perform write operations. The scope controls what the token can request, and the admin role controls what the app can actually do. I discovered this when my manage-scoped token still got 403 Forbidden until I assigned an Organization Administrator role. After completing a task, I revoke elevated scopes to maintain least-privilege."
