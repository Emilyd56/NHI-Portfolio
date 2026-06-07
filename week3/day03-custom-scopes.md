# Week 3, Day 3: Create Custom Scopes for a Mock Protected API

**Date**: June 6, 2026  
**Quiz Score**: 5/5

---

## 1. Core Idea

Okta's built-in scopes (`okta.users.read`, `okta.users.manage`) are for Okta's own APIs. When you build your **own** API, you define your **own** scopes.

Today:
1. Created a custom authorization server in Okta
2. Defined custom scopes for a mock "Orders API"
3. Got tokens with those custom scopes
4. Learned how APIs enforce scopes and audiences

---

## 2. Concept Breakdown

### Built-in vs Custom Scopes

| Type | Example | Who Defines | Who Enforces |
|------|---------|-------------|--------------|
| Built-in | `okta.users.read` | Okta | Okta's APIs |
| Custom | `orders:read` | You | Your API |

### Authorization Servers in Okta

| Type | Purpose | Token Audience |
|------|---------|----------------|
| Org Authorization Server | Okta's own APIs | `https://your-domain.okta.com` |
| Custom Authorization Server | Your APIs | Whatever you define (e.g., `api://orders`) |

---

## 3. Hands-On Lab: Build a Custom Authorization Server

### Step 1: Create Authorization Server

1. Okta Admin → **Security** → **API** → **Add Authorization Server**
2. Name: `Orders API`, Audience: `api://orders`

### Step 2: Add Custom Scopes

In the **Scopes** tab:
- `orders:read` - Read order data
- `orders:write` - Create, update, delete orders

### Step 3: Create Access Policy

In **Access Policies** tab:
- Policy: `Orders API Policy` → All clients
- Rule: `Allow orders scopes` → Client Credentials, Any scopes

### Step 4: Request Token with Custom Scopes

```powershell
$customIssuer = "https://org1-pro-7fe0e.oktapreview.com/oauth2/ause0dciqsf73P1Rw0x7"
$customTokenEndpoint = "$customIssuer/v1/token"

$response = Invoke-WebRequest -Uri "https://$oktaDomain" -Method HEAD -UseBasicParsing
$oktaTime = [int]([datetime]::Parse($response.Headers["Date"]).ToUniversalTime() - [datetime]"1970-01-01").TotalSeconds

$jwt = New-SignedJwt -clientId $clientId -audience $customTokenEndpoint -kid $kid -iat $oktaTime -exp ($oktaTime + 300) -rsa $rsa

$body = "grant_type=client_credentials&client_id=$clientId&client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer&client_assertion=$jwt&scope=orders:read"

$customToken = (Invoke-RestMethod -Uri $customTokenEndpoint -Method POST -ContentType "application/x-www-form-urlencoded" -Body $body).access_token
```

### Step 5: Decode Token

```powershell
$payload = $customToken.Split(".")[1]
$padding = 4 - ($payload.Length % 4)
if ($padding -ne 4) { $payload += "=" * $padding }
[System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($payload.Replace("-","+").Replace("_","/")))
```

**Result**:
```json
{
  "aud": "api://orders",
  "scp": ["orders:read"],
  "iss": "https://org1-pro-7fe0e.oktapreview.com/oauth2/ause0dciqsf73P1Rw0x7"
}
```

### Lab Results

| Request | Result |
|---------|--------|
| `orders:read` | Token with `["orders:read"]` |
| `orders:read orders:write` | Token with `["orders:read","orders:write"]` |
| `orders:delete` (undefined) | `invalid_scope` error |

---

## 4. Audience Explained

**Audience (`aud`)** = WHO this token is intended for.

| Protection | What It Limits |
|------------|----------------|
| **Scope** | WHAT you can do |
| **Audience** | WHERE you can do it |
| **Lifetime** | HOW LONG you can do it |

A token with `aud: api://orders` will be rejected by any API that isn't the Orders API.

---

## 5. Practice Questions (with Answers)

**Q1**: What's the difference between Org Authorization Server and Custom Authorization Server?

**A1**: Org Authorization Server issues tokens for Okta's APIs. Custom Authorization Server issues tokens for your own APIs.

**Q2**: You created `orders:read` and `orders:write` but only requested `orders:read`. What's in the token?

**A2**: Only `orders:read` - tokens contain what you request, following least-privilege.

**Q3**: A client requests `orders:delete` which doesn't exist. What happens?

**A3**: `invalid_scope` error - authorization server rejects undefined scopes.

**Q4**: Token has `"aud":"api://orders"`. What does this mean?

**A4**: The audience is the intended recipient. This token is meant only for the Orders API. Other APIs should reject it.

**Q5**: An NHI needs to read and create orders. What scopes should it request?

**A5**: `orders:read` and `orders:write` only - not everything available. Least-privilege.

---

## 6. Key Takeaways

1. **Custom auth servers** issue tokens for YOUR APIs with YOUR scopes
2. **You define what exists** - only defined scopes can be requested
3. **Client chooses what to request** - token contains only requested scopes
4. **Audience limits WHERE** - token for Orders API won't work elsewhere
5. **Same client, multiple tokens** - one service app can get tokens from different auth servers

---

## 7. Portfolio Seed

> "I created a custom authorization server in Okta with custom scopes for a mock Orders API. The token had `aud: api://orders` - limiting WHERE it could be used - and `scp: orders:read` - limiting WHAT it could do. When I requested an undefined scope, I got `invalid_scope`. This showed me how API owners define permission boundaries and how audience + scope together contain blast radius."
