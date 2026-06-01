# Week 1, Day 1: The Core Idea: Non-Human Identities in Okta

A **non-human identity** is a digital identity used by a system, application, automation, workload, or agent to access something without being a human user.

In Okta, one practical implementation is an **API Service app** that uses OAuth 2.0 to obtain a scoped access token.

---

# 1. The Core IAM Concept

A human user authenticates like this:

```
User → username/password/MFA → Okta → app access
```

A non-human identity authenticates differently:

```
Service app → credentials → Okta authorization server → access token → API access
```

The IAM question is not just "did the service authenticate?" but:

```
What identity did we create?
What credential does it use?
What scopes can it request?
What can the token access?
Who owns this identity?
Can it be revoked, rotated, logged, and reviewed?
```

That is the NHI lens.

---

# 2. What You're Implementing

```
Create Okta API Service app
→ configure authentication method
→ assign limited OAuth scopes
→ generate credentials (key pair or secret)
→ request an access token
→ decode the token
→ call an API with the token
→ document the IAM meaning
```

---

# 3. Hands-On Okta Lab

## Step 1: Create the Service App

In Okta Admin Console:

```
Applications → Applications → Create App Integration
Sign-in method: API Services
Name: nhi-lab-day1
```

Naming matters for governance - the name should communicate purpose and context.

## Step 2: Configure Authentication

For Okta's **Org Authorization Server** (which grants access to Okta's management API like `okta.users.read`), Okta REQUIRES **private_key_jwt** authentication. Client secrets are blocked for this high-value API.

In the app **General** tab → **Client Credentials**:
- Set **Client authentication** to **Public key / Private key**
- Click **Add key** → **Generate new key**
- Copy the JSON output (contains both public and private key components)
- Save the JSON to a local file (not committed to any repo)

Note the **Key ID (kid)** Okta assigns - you'll need it for the JWT header.

## Step 3: Disable DPoP (For This Lab)

Uncheck **Require Demonstrating Proof of Possession (DPoP) header in token requests**.

DPoP is a sender-constrained token mechanism (more secure than bearer tokens), but adds complexity. For learning the basics, we use plain bearer tokens.

## Step 4: Assign Limited Scope

In the app **Okta API Scopes** tab, grant:

```
okta.users.read
```

This is read-only access to user data. Least privilege.

## Step 5: Build a Signed JWT Assertion

The JWT assertion is what the service app sends to prove its identity. It has three parts:

**Header**:
```json
{ "alg": "RS256", "typ": "JWT", "kid": "<your kid>" }
```

**Payload**:
```json
{
  "iss": "<client_id>",
  "sub": "<client_id>",
  "aud": "https://<your-domain>/oauth2/v1/token",
  "iat": <current unix timestamp>,
  "exp": <iat + 30 seconds>,
  "jti": "<random uuid>"
}
```

**Signature**: RSA-SHA256 signature of `base64url(header) + "." + base64url(payload)` using your private key.

The final JWT is: `header.payload.signature`

## Step 6: Exchange JWT for Access Token

POST to the token endpoint:

```
POST https://<your-domain>/oauth2/v1/token
Content-Type: application/x-www-form-urlencoded

grant_type=client_credentials
&client_id=<client_id>
&client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer
&client_assertion=<signed JWT>
&scope=okta.users.read
```

Successful response:
```json
{
  "access_token": "eyJ...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "scope": "okta.users.read"
}
```

## Step 7: Decode the Access Token

The access token is itself a JWT. Decode the payload to see claims:

| Claim | Meaning |
|-------|---------|
| `iss` | Authorization server that minted the token |
| `aud` | Resource server that should accept the token |
| `sub` | Identity the token represents (= client_id for service app) |
| `cid` | Client ID that requested the token |
| `scp` | Granted scopes |
| `iat` | Issued at |
| `exp` | Expires at |
| `jti` | Unique token ID |
| `ver` | Token version |

**Key observation**: For a service app, `sub` = `cid` = client_id. The token represents the app acting as itself (application permission), not on behalf of a user (delegated permission).

## Step 8: Call the API

Use the token in the Authorization header:

```
GET https://<your-domain>/api/v1/users?limit=1
Authorization: Bearer <access_token>
```

HTTP 200 = token authenticated and authorized successfully.

---

# 4. Common Errors and What They Teach

| Error | IAM Lesson |
|-------|------------|
| `invalid_client` (bad secret) | Secrets shown once - rotation = regenerate |
| `invalid_dpop_proof` | DPoP is sender-constrained - prevents token theft |
| `must use private_key_jwt` | High-value APIs enforce asymmetric auth |
| `client_assertion expired` | JWT timestamp vs server clock matters |
| `expiration too far into future` | Max assertion lifetime enforced |
| `must be issued before current time` | iat must be <= server's "now" |

Each error maps to an IAM concept. Failures are learning.

---

# 5. Vendor-Neutral Abstraction

| Okta Object | Portable Pattern |
|-------------|------------------|
| API Service app | OAuth client / machine identity |
| Public/private key pair | Asymmetric machine credential |
| Okta API scope | Permission boundary |
| Signed JWT assertion | Cryptographic proof of identity |
| Access token | Time-bound authorization artifact |
| System Log | Audit evidence |

---

# 6. Outside-Okta Mapping

| Pattern | Other Environments |
|---------|-------------------|
| private_key_jwt | Google service account keys, Entra cert auth, GitHub App private keys |
| Service app client credentials | Auth0 M2M, Keycloak service accounts, Entra app registrations |
| Token endpoint | AWS STS, GCP token endpoint, any OAuth IdP |
| Bearer access token | All OAuth 2.0 tokens |

---

# 7. Apply the 17 Questions

For the service app you created:

1. **Identity**: Okta API Service app
2. **Human/NHI**: Non-human
3. **NHI type**: OAuth client / service app
4. **Owner**: You
5. **Purpose**: Lab - learn machine identity
6. **Owner valid**: Yes
7. **Credential**: Private key (RSA-2048)
8. **Storage**: Local file, not in repo
9. **Age**: Just created
10. **Rotatable**: Yes (generate new key in Okta)
11. **Revocable**: Yes (delete key or app)
12. **Access**: okta.users.read
13. **Lifetime**: Token 1h; Key indefinite
14. **Least-privilege**: Yes (read-only, scoped)
15. **Logged**: Yes (Okta System Log)
16. **Last used**: Now
17. **Blast radius**: Low (read-only)

---

# 8. Practice Questions

## Token Claims & Identity

**Q1**: In your access token, `sub` = `cid` = your client ID. What does this tell you about the identity model? How would this be different if a *user* had signed in?

**Q2**: Why does it matter that `sub` and `cid` are the same value? What does this mean for blast radius if the token is compromised?

**Q3**: If `sub` represented a user ID instead of the client ID, what would that change about how the API interprets the request?

## Credentials & Lifecycle

**Q4**: The access token expires in 1 hour. The private key does not expire automatically. Which is the bigger credential risk and why?

**Q5**: You accidentally committed your private key JSON to GitHub (even to a private repo). What are your immediate actions? List them in order.

**Q6**: Why does Okta BLOCK client secrets for the Org Authorization Server and REQUIRE private_key_jwt? What security principle is being enforced?

## Scopes & Authorization

**Q7**: You created a service app but forgot to assign any scopes in Okta. What happens when you request a token with `scope=okta.users.read`?

**Q8**: If you wanted to grant this service app the ability to create AND delete users, what scope would you need? How does the blast radius change?

**Q9**: Your app has `okta.users.read` scope. Can it read ALL users in the tenant, or just specific ones? What controls this?

## Governance & Operations

**Q10**: Where in Okta would you look to see if this service app has been used? What evidence would you look for?

**Q11**: The developer who created this service app is leaving the company next week. What governance actions should happen BEFORE they leave?

**Q12**: It's been 6 months since this app was created. You're doing an access review. What questions do you ask?

---

## Answers

*(Review these AFTER attempting to answer on your own)*

**A1**: `sub` = `cid` means the token represents the **app acting as itself** (application permission). If a user signed in, `sub` would be the user's ID and `cid` would be the app's ID - the app would be acting **on behalf of** the user (delegated permission).

**A2**: When `sub` = `cid`, the blast radius is whatever the **app** can do, not limited by any user's permissions. A compromised token has the app's full granted scope. In delegated flow, blast radius is limited to the intersection of app AND user permissions.

**A3**: The API would treat the request as coming from that user, subject to the user's permissions. Actions would be logged as the user, not the app. The app would only be able to do what that specific user is allowed to do.

**A4**: The private key is the bigger risk. The token expires automatically after 1 hour - self-healing. The private key never expires - if compromised, the attacker can mint unlimited tokens until you discover the breach and rotate the key.

**A5**: Immediate actions in order:
1. Revoke/delete the key in Okta immediately
2. Generate a new key pair
3. Update your local key file
4. Audit Okta System Log for any suspicious activity using the old key
5. Rotate any other secrets in that repo
6. Consider the repo compromised - review for other exposed credentials

**A6**: Okta enforces the principle that high-value APIs (management APIs that can read/modify the tenant) require **stronger authentication**. Asymmetric auth means the private key never leaves your machine - no shared secret to intercept or replay. This is security by platform design, not by policy document.

**A7**: You get an error: `invalid_scope`. The scope must be granted to the app in Okta's configuration before it can be requested in a token. The app can only request scopes it's been pre-authorized for.

**A8**: You'd need `okta.users.manage` (or similar manage/admin scope). Blast radius changes dramatically: compromised token can now create rogue admin accounts, delete users, modify permissions - not just read data. Read-only is containment; write access is potential full compromise.

**A9**: With `okta.users.read`, the app can read ALL users in the tenant. The scope is the permission boundary, not individual user ACLs. This is why even "read" access has risk - it's full data exfiltration potential.

**A10**: Okta System Log. Look for:
- `app.oauth2.token.grant.client_credentials` events for token issuance
- API request events showing the client ID
- Failed authentication attempts
- Any unusual patterns (off-hours usage, unusual IP addresses)

**A11**: Before the developer leaves:
1. Transfer ownership of the service app to another person/team
2. Document the app's purpose and dependencies
3. Rotate the private key (developer may have a copy)
4. Review and update any runbooks or documentation
5. Ensure someone else knows how to operate, troubleshoot, and decommission it

**A12**: Questions for the 6-month access review:
- Is this app still needed? What business process depends on it?
- Is the owner still valid? Still at the company? Still responsible?
- Has the scope changed? Does it still need `okta.users.read` or can it be reduced?
- When was it last used? (Check System Log)
- Is the key being rotated on a schedule?
- Are the audit logs being reviewed?
- What would happen if we disabled it right now?

---

# 9. Day 1 Output

By the end of Week 1, Day 1, you should have:

```
1. Okta API Service app created
2. Private/public key pair generated and configured
3. Minimal scope assigned (okta.users.read)
4. Signed JWT assertion built and exchanged for access token
5. Token decoded and claims documented
6. API call made with the token (HTTP 200)
7. 17 questions applied
8. Artifact created: week1/day1-okta-service-app.md
9. Practice questions answered
```
