# Week 1 Day 1: Lab Notes and Troubleshooting

This documents the real issues encountered while implementing the `private_key_jwt` authentication flow with Okta.

## The Goal

Create an Okta API Service app, authenticate using `private_key_jwt`, obtain an access token, and call the Okta Users API.

## What Worked Immediately

- Creating the API Service app in Okta
- Assigning the `okta.users.read` scope
- Generating a key pair in Okta

## Errors Encountered

### Error 1: `invalid_client` - "The client secret supplied is invalid"

**Cause**: Initially tried to use client secret authentication.

**Learning**: Okta's Org Authorization Server (which issues tokens for Okta API scopes like `okta.users.read`) **requires** `private_key_jwt` authentication. Client secrets are blocked for this high-value API.

**IAM insight**: This is security by platform design - forcing stronger authentication for management APIs.

---

### Error 2: `invalid_dpop_proof` - "The DPoP proof JWT header is missing"

**Cause**: The app had "Require Demonstrating Proof of Possession (DPoP) header in token requests" enabled by default.

**Fix**: Unchecked this setting in the app's General tab.

**IAM insight**: DPoP is a sender-constrained token mechanism that prevents token theft/replay. More secure than plain bearer tokens, but adds complexity. For learning the basics, we use plain bearer tokens first.

---

### Error 3: `invalid_client` - "The client_assertion token is expired"

**Cause**: The `iat` (issued-at) and `exp` (expiration) timestamps in the JWT assertion were in the past from Okta's perspective.

**Initial attempts**:
- Used `Get-Date -UFormat %s` - unreliable on Windows
- Used `[datetime]::UtcNow` calculation - correct but still failed

**Root cause**: Clock skew between local machine and Okta servers. My machine's date was set far in the future from Okta's actual server time.

---

### Error 4: `invalid_client` - "The client_assertion token has an expiration too far into the future"

**Cause**: Same clock skew issue, but the opposite direction during debugging.

**Learning**: JWT timestamps must be within a narrow window of the server's clock:
- `iat` must be <= server's "now"
- `exp` must be > server's "now" but not too far ahead

---

### Error 5: `invalid_client` - "must be issued before current time"

**Cause**: Still clock skew - the `iat` timestamp was in the future from Okta's perspective.

---

## The Clock Skew Solution

Created a discovery script that:
1. Makes a probe request to Okta to get HTTP headers
2. Reads the `Date` header to find Okta's server time
3. Uses that timestamp for JWT assertion creation

**Key lesson**: When working with JWTs across systems, timestamp alignment matters. This is especially important for:
- CI/CD systems with drifted clocks
- Virtual machines with paused time
- Testing environments

---

## Final Working Flow

1. Load private key from JSON file
2. Build JWT header: `{ "alg": "RS256", "typ": "JWT", "kid": "<key_id>" }`
3. Build JWT payload with:
   - `iss` = client ID
   - `sub` = client ID
   - `aud` = token endpoint URL
   - `iat` = current timestamp (server-aligned)
   - `exp` = iat + 30 seconds
   - `jti` = unique UUID
4. Sign with private key using RS256
5. POST to token endpoint with:
   - `grant_type=client_credentials`
   - `client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer`
   - `client_assertion=<signed JWT>`
   - `scope=okta.users.read`
6. Receive access token
7. Use token to call Okta Users API

---

## IAM Lessons Learned

| Issue | IAM Principle |
|-------|---------------|
| Okta blocks client secrets for Org Auth Server | High-value APIs enforce stronger authentication |
| DPoP enabled by default | Sender-constrained tokens are becoming standard |
| JWT timestamps must align | Distributed systems need clock synchronization |
| Private key stays local | Asymmetric auth = private key never transmitted |
| Token is time-bound | Authorization is ephemeral, not permanent |

---

## Token Claims Observed

After successful authentication:

```
iss: https://<domain>/oauth2/default
aud: https://<domain>
sub: <client_id>
cid: <client_id>
scp: okta.users.read
```

**Key observation**: `sub` = `cid` = client ID. This means the token represents the **app acting as itself** (application permission), not on behalf of a user (delegated permission).

---

## Portfolio Insight

> "The errors taught more than the documentation. Each failure mapped to an IAM concept: why Okta requires asymmetric auth for high-value APIs, why DPoP exists for token binding, why clock alignment matters for JWTs. The troubleshooting *was* the curriculum."
