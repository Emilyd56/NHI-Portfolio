# Week 1, Day 2: Token Claims, Audience, Scopes, and OAuth Errors

---

## 1. The Core Idea

An access token isn't just a password that grants access. It's a **signed evidence packet** that contains claims - statements about who the token represents, what it can do, when it expires, and who should accept it.

When a resource server (API) receives a token, it doesn't call back to Okta to ask "is this valid?" Instead, it reads the claims inside the token and makes decisions based on what it finds.

Understanding token claims means understanding what the API sees when your NHI shows up at the door.

---

## 2. The Eight Core Claims

| Claim | Full Name | What It Answers |
|-------|-----------|-----------------|
| `iss` | Issuer | Who minted this token? |
| `sub` | Subject | Who does this represent? |
| `aud` | Audience | Who should accept this? |
| `cid` | Client ID | Which app requested it? |
| `scp` | Scope | What can it do? |
| `iat` | Issued At | When was it created? |
| `exp` | Expires At | When does it die? |
| `jti` | JWT ID | What's its unique ID? |

---

## 3. Claim Details

### iss (Issuer)
The URL of the authorization server that created the token. The API checks this to ensure the token came from a trusted source.

**IAM meaning**: Trust anchor.

### sub (Subject)
The identity the token represents. For service apps, `sub` = client ID. For user flows, `sub` = user ID.

**IAM meaning**: The "who" in the audit log.

### aud (Audience)
The intended recipient of the token. Prevents token reuse attacks - a token for API-A won't work on API-B.

**IAM meaning**: Security boundary.

### cid (Client ID)
The application that requested the token. Even in delegated flows, `cid` tells you which app was involved.

**IAM meaning**: Attribution.

### scp (Scope)
The permissions granted in this token. The token can only do what scopes allow.

**IAM meaning**: Authorization boundary.

### iat (Issued At)
Unix timestamp when the token was created. Used with `exp` to define lifetime.

**IAM meaning**: Temporal evidence.

### exp (Expires At)
Unix timestamp when the token becomes invalid. Short-lived = limited blast radius.

**IAM meaning**: Automatic revocation.

### jti (JWT ID)
Unique identifier for this specific token. Enables revocation and replay detection.

**IAM meaning**: Audit correlation.

---

## 4. Why Audience Matters

**The attack**:
1. Attacker gets token meant for API-A
2. Attacker sends token to API-B
3. Without audience validation, API-B accepts it

**The defense**:
- Token has `aud = "api://api-a"`
- API-B checks `aud`, sees wrong value, rejects token

**The rule**: A well-configured API rejects tokens where `aud` doesn't match its own identifier.

---

## 5. Scope Levels

| Level | Typical Name | Blast Radius |
|-------|--------------|--------------|
| Read | `.read` | Data exfiltration |
| Write | `.write` | Data modification |
| Manage | `.manage` | Full CRUD |
| Admin | `.admin` | Config + data |

**Key insight**: Start with lowest scope. You can add more later. You can't un-leak data.

---

## 6. OAuth Error Playbook

| Error | What It Means | IAM Lesson |
|-------|---------------|------------|
| `invalid_client` | Credential wrong/missing | Authentication failed |
| `invalid_scope` | Scope not granted to app | Authorization not configured |
| `invalid_grant` | Grant type not allowed | Flow not permitted |
| `invalid_dpop_proof` | DPoP required but wrong | Sender constraint not met |
| `client_assertion expired` | JWT `exp` in past | Timestamp validation |
| `expiration too far in future` | JWT `exp` too far ahead | Clock skew/policy |
| `must be issued before current time` | JWT `iat` in future | Clock skew |

---

## 7. Vendor-Neutral Abstraction

| Okta Concept | Portable Pattern |
|--------------|------------------|
| Access token claims | JWT standard claims (RFC 7519) |
| `aud` validation | Token binding / audience restriction |
| Okta scopes | OAuth 2.0 scopes |
| Org Authorization Server | First-party API authorization |
| Custom Authorization Server | Third-party API authorization |

---

## 8. Outside-Okta Mapping

| Concept | Okta | Entra ID | Auth0 | AWS Cognito |
|---------|------|----------|-------|-------------|
| Issuer | Okta domain | login.microsoftonline.com | Auth0 tenant | cognito-idp.region.amazonaws.com |
| Audience | Domain or custom | App ID URI | API identifier | User pool client |
| Scopes | Okta API scopes | MS Graph scopes | API permissions | Cognito scopes |

---

## 9. Token as Evidence

A token is an evidence artifact:
- **Who**: `sub` identifies the actor
- **What**: `scp` lists permitted actions
- **Where**: `aud` specifies the target
- **When**: `iat`/`exp` bound the time window
- **By whom**: `iss` names the authority

---

## 10. Practice Questions

1. What claim tells you who minted the token? → `iss`
2. If `sub` = `cid`, is this a service app or user flow? → Service app
3. What does `aud` prevent? → Token reuse across APIs
4. Can you delete users with `scp: okta.users.read`? → No (read only)
5. Token `exp` is 3600s after `iat`. How long valid? → 1 hour
6. `invalid_scope` error means what? → Scope not granted to app

---

## 11. Portfolio Seed

> "Every OAuth access token contains claims that answer who, what, where, and when. The `sub` claim identifies the actor, `scp` defines permissions, `aud` restricts which API accepts it, and `exp` automatically revokes it. For NHIs using client credentials, `sub` equals `cid` because the app acts as itself. Understanding these claims is essential for debugging OAuth errors and auditing API access."
