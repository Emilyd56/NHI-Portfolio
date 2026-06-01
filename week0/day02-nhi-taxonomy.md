# Day 0.2: The Core Idea: NHI Taxonomy - The Six Core Types

Not all non-human identities are the same.

A GitHub Actions workflow is not the same as an Okta service app. An AWS IAM role assumed by a Lambda function is not the same as a PAT stored in a developer's `.env` file.

Classification matters because:

```
Different NHI types have different credential models
Different NHI types have different lifecycle triggers
Different NHI types have different governance controls
```

If you treat all NHIs the same, you will over-govern some and under-govern others.

---

# 1. The Six Core NHI Types

## Type 1: OAuth Client / Service App

```
What it is:    An application registered with an identity provider to request tokens
Examples:      Okta API Service app, Entra app registration, Auth0 M2M app, Keycloak client
Credential:    Client secret, private key, certificate
How it works:  Uses OAuth flows (usually client_credentials) to get access tokens
```

**Primary IAM concern**: Scope management, client credential security, token audience validation, owner assignment.

---

## Type 2: Service Account

```
What it is:    A named account for a system or application, not tied to OAuth
Examples:      Database service user, SaaS integration account, legacy automation user, shared mailbox
Credential:    Username/password, API key, or platform-specific credential
How it works:  Authenticates like a user but is not a person
```

**Primary IAM concern**: Ownership ambiguity, credential sharing, overpermissioning, stale access, no MFA.

---

## Type 3: CI/CD Identity

```
What it is:    The identity a build/deploy pipeline uses to access resources
Examples:      GitHub Actions workflow, GitLab CI runner, Jenkins agent, CircleCI job
Credential:    OIDC token (federated), or static secret/key (legacy)
How it works:  Modern: OIDC federation to cloud provider. Legacy: stored secrets in CI config.
```

**Primary IAM concern**: Trust policy design (which repos/branches can assume roles), claim validation, environment boundaries, secret leakage in logs.

---

## Type 4: Cloud Workload Identity

```
What it is:    An identity assigned to compute running in a cloud environment
Examples:      AWS IAM role for EC2/Lambda, Azure managed identity, GCP service account with WIF, Kubernetes service account
Credential:    Short-lived token from cloud metadata service or OIDC federation
How it works:  Workload requests credentials from cloud platform at runtime, no static secrets
```

**Primary IAM concern**: Trust policy scope, resource permissions, workload attestation, avoiding static keys.

---

## Type 5: Secret-Bearing App

```
What it is:    Any application holding a static credential to access something
Examples:      API key in config file, PAT in environment variable, client secret in Vault, signing key in HSM
Credential:    The secret itself (API key, PAT, password, key material)
How it works:  App retrieves or embeds secret, uses it to authenticate
```

**Primary IAM concern**: Secret storage location, rotation frequency, leakage risk, age, owner, blast radius if exposed.

---

## Type 6: AI Agent / MCP Client

```
What it is:    An AI system that calls APIs or tools, potentially on behalf of a user
Examples:      Support agent reading/writing tickets, coding agent calling MCP tools, automation bot in Slack
Credential:    OAuth token (acting as self), delegated token (acting on behalf of user), API key
How it works:  Agent receives instructions, decides which tools to call, authenticates to resources
```

**Primary IAM concern**: Delegation model (self vs on-behalf-of), tool permissions (read/write/delete), destructive action approval, prompt injection as authorization bypass, audit trail.

---

# 2. How Types Overlap

These types are not mutually exclusive:

```
A GitHub Actions workflow (CI/CD identity) may use OIDC to assume an AWS role (cloud workload identity)

An AI agent (AI agent / MCP client) may authenticate using an OAuth service app (OAuth client)

A backend service (service account) may retrieve secrets from Vault (secret-bearing app pattern)
```

The question is not "which single type is this?" but:

```
What identity patterns are present?
Which governance controls apply?
```

---

# 3. Mapping Types to Governance

| NHI Type | Credential Risk | Lifecycle Trigger | Key Governance Control |
|----------|----------------|-------------------|------------------------|
| OAuth client / service app | Client secret leakage | App decommission | Scope review, secret rotation |
| Service account | Password/key sharing | System retirement (often missed) | Owner assignment, access review |
| CI/CD identity | Trust policy too broad | Pipeline deprecation | Claim-based trust, environment boundaries |
| Cloud workload identity | Trust policy misconfiguration | Workload termination | Least-privilege policy, no static keys |
| Secret-bearing app | Secret in wrong place | Secret rotation overdue | Secret scanning, rotation automation |
| AI agent / MCP client | Over-scoped tool access | Agent deprecation | Tool permission matrix, approval gates |

---

# 4. Failure Modes

**Treating all NHIs as service accounts**

```
Result: Miss OIDC federation opportunities, over-rely on static secrets
Risk: Longer credential lifetimes than necessary
```

**Ignoring AI agents as NHIs**

```
Result: Agents get ad-hoc API keys, no tool permission model
Risk: Uncontrolled access to destructive actions
```

**Not mapping CI/CD to workload identity**

```
Result: Pipelines store long-lived cloud credentials
Risk: Key leakage in logs, repos, or CI config
```

**No type-specific inventory**

```
Result: Cannot answer "how many OAuth clients do we have vs service accounts vs CI/CD identities"
Risk: Governance gaps, unknown attack surface
```

---

# 5. Practice Questions

**Q1**: A Lambda function assumes an IAM role to read from S3. What NHI type is the Lambda's identity?

**A1**: Cloud workload identity.

**Q2**: A developer stores a GitHub PAT in a `.env` file to authenticate API requests. What NHI type pattern is this?

**A2**: Secret-bearing app.

**Q3**: An Okta API Service app uses client credentials to call the Okta Users API. What NHI type is this?

**A3**: OAuth client / service app.

**Q4**: A GitHub Actions workflow uses OIDC to assume an AWS role and deploy to production. What NHI types are involved?

**A4**: Two types: CI/CD identity (GitHub Actions workflow) + Cloud workload identity (AWS IAM role assumed via OIDC).

**Q5**: An AI coding assistant uses an OAuth token to call MCP tools that can read, create, and delete files. What NHI type is this, and what's the primary IAM concern?

**A5**: AI agent / MCP client. Primary concerns: tool permission scope, destructive action approval, delegation model, audit trail.

**Q6**: A Jenkins server has a service account with the username `jenkins-deploy` and a password stored in Jenkins credentials. What NHI type is this?

**A6**: Service account.

---

# 6. Day 0.2 Output

By the end of Day 0.2, you should have:

```
1. Understanding of the six core NHI types
2. Ability to classify real-world scenarios
3. Artifact created: week0/day2-nhi-taxonomy.md
4. Practice questions answered
```
