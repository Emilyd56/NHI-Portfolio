# Day 0.3: The Core Idea: Authentication Methods for NHIs

Authentication answers:

```
How does this identity prove it is who it claims to be?
```

For humans, this is usually passwords + MFA. For NHIs, the options are different - and the security properties vary dramatically.

The key insight:

```
Static secrets are the fallback, not the ideal.
The goal is short-lived, federated, or attested credentials where possible.
```

---

# 1. The Authentication Methods

## Method 1: Client Secret (Shared Secret)

```
What it is:    A static string known by both the client and the server
How it works:  Client sends secret with request; server validates it matches
Examples:      OAuth client_secret, database password, API password
```

**Security properties:**

```
Symmetric:     Both parties know the secret
Static:        Doesn't change unless rotated
Replayable:    Anyone with the secret can use it
No attribution: Cannot distinguish which system used it if shared
```

**Risk**: If leaked, attacker has full access until rotation. No way to detect misuse without anomaly detection.

---

## Method 2: API Key (Bearer Credential)

```
What it is:    A static token that grants access when presented
How it works:  Client includes key in header or query param; server validates
Examples:      GitHub PAT, Stripe API key, Supabase anon key, SendGrid key
```

**Security properties:**

```
Bearer token:  Whoever holds it can use it
Static:        Long-lived unless manually rotated
Often unscoped: Many API keys grant broad access
No sender binding: Key works from any source
```

**Risk**: Easiest to leak (logs, repos, screenshots). Often over-privileged. Rotation often breaks things.

---

## Method 3: Private Key JWT (Asymmetric Assertion)

```
What it is:    Client signs a JWT with its private key; server validates with public key
How it works:  Client generates JWT assertion, signs it, sends to token endpoint
Examples:      OAuth private_key_jwt, Google service account key, Entra certificate auth
```

**Security properties:**

```
Asymmetric:    Private key never leaves the client
Non-replayable: JWT includes timestamps, audience, jti (can enforce one-time use)
Attributable:  Signature proves which key signed it
```

**Risk**: Private key must be protected. If key leaks, attacker can mint assertions. Key rotation more complex than secret rotation.

---

## Method 4: OIDC Federation (Short-Lived, Attested)

```
What it is:    Workload gets token from trusted IdP; target validates token claims
How it works:  CI/CD or cloud workload requests token from platform IdP, presents to resource
Examples:      GitHub Actions OIDC → AWS, GCP Workload Identity Federation, Azure federated credentials
```

**Security properties:**

```
Short-lived:   Tokens expire in minutes
No static secret: Nothing to leak in repos
Claim-based:   Access depends on claims (repo, branch, environment, workflow)
Attested:      IdP vouches for workload identity
```

**Risk**: Trust policy misconfiguration. If claims are too broad (e.g., any repo can assume role), federation becomes a backdoor.

---

## Method 5: Certificate / mTLS (Mutual Authentication)

```
What it is:    Client presents X.509 certificate; server validates certificate chain
How it works:  TLS handshake includes client cert; server checks CA trust and cert attributes
Examples:      mTLS between services, Kubernetes pod identity, SPIFFE SVIDs
```

**Security properties:**

```
Mutual:        Both client and server authenticate
Bound to connection: Certificate tied to TLS session
Attributable:  Certificate subject identifies the client
Revocable:     CRL or OCSP can revoke certificates
```

**Risk**: Certificate management complexity. CA compromise = total compromise. Expiration handling required.

---

## Method 6: SPIFFE / SPIRE (Workload Attestation)

```
What it is:    Workloads receive cryptographic identity (SVID) based on verified attributes
How it works:  SPIRE agent attests workload (process, container, VM), issues short-lived SVID
Examples:      SPIFFE SVID for service mesh, Kubernetes workload identity via SPIRE
```

**Security properties:**

```
Attested:      Identity based on workload attributes, not just secrets
Short-lived:   SVIDs rotate frequently (minutes to hours)
Platform-verified: SPIRE verifies workload before issuing identity
Zero static secrets: No secrets deployed with workload
```

**Risk**: Requires SPIRE infrastructure. Attestation misconfiguration can issue SVIDs to wrong workloads.

---

# 2. Security Ranking

From weakest to strongest (general guidance, not absolute):

```
1. API Key           - Static, bearer, often unscoped, easy to leak
2. Client Secret     - Static, symmetric, replayable
3. Private Key JWT   - Asymmetric, but key still needs protection
4. Certificate/mTLS  - Strong binding, but CA management overhead
5. OIDC Federation   - Short-lived, no static secret, claim-based
6. SPIFFE/SPIRE      - Attested, short-lived, zero secrets deployed
```

The trend in modern NHI security:

```
Move UP this list wherever possible
Static secrets → Federated tokens → Attested identity
```

---

# 3. Credential Lifetime Comparison

| Method | Typical Lifetime | Rotation Trigger |
|--------|------------------|------------------|
| API Key | Months to years | Manual or policy |
| Client Secret | Months to years | Manual or policy |
| Private Key JWT | Key: years; Assertion: minutes | Key rotation policy |
| OIDC Federation | Minutes | Automatic (each request) |
| Certificate/mTLS | Days to months | Cert expiration |
| SPIFFE SVID | Minutes to hours | Automatic rotation |

---

# 4. Failure Modes

**Relying on API keys for production workloads**

```
Result: Long-lived credential in config files, CI vars, developer machines
Risk: Leak in repo, logs, or screenshot; no easy rotation without outage
```

**Using client secrets when private_key_jwt is available**

```
Result: Symmetric secret shared with authorization server
Risk: Secret can be replayed if intercepted; harder to attribute
```

**OIDC trust policy too broad**

```
Result: Any repo or branch can assume the cloud role
Risk: Compromised or malicious workflow gets production access
```

**Not rotating certificates before expiration**

```
Result: Expired cert causes auth failure
Risk: Outage, or worse - rushed bypass of security controls
```

---

# 5. Practice Questions

**Q1**: A backend service authenticates to a database using a username and password stored in AWS Secrets Manager. What authentication method is this?

**A1**: Client secret (static shared secret).

**Q2**: A GitHub Actions workflow requests an OIDC token and uses it to assume an AWS IAM role. What authentication method is the workflow using to access AWS?

**A2**: OIDC federation.

**Q3**: An Okta service app can be configured for client_secret or private_key_jwt. Which is stronger and why?

**A3**: Private key JWT - asymmetric (private key never leaves client), unlike client secret which is symmetric (both parties know it).

**Q4**: What is the main advantage of OIDC federation over static API keys for CI/CD pipelines?

**A4**: Short-lived tokens (minutes), no static secret to leak, automatic expiration, no rotation-induced outages.

**Q5**: A Kubernetes pod authenticates to another service using a SPIFFE SVID. What makes this different from using a mounted secret?

**A5**: Attestation-based identity (workload proves what it is, not what it knows), no static secrets deployed, automatic rotation.

**Q6**: An API key for a third-party service was created 2 years ago and has never been rotated. What is the IAM risk?

**A6**: Key may already be compromised (leaked long ago without detection). Whoever has the key has full access. No way to know if it's been misused.

---

# 6. Day 0.3 Output

By the end of Day 0.3, you should have:

```
1. Understanding of 6 NHI authentication methods
2. Ability to rank methods by security strength
3. Artifact created: week0/day3-authn-methods.md
4. Practice questions answered
```
