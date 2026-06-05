# NHI IAM Lab

Hands-on IAM lab focused on **Non-Human Identities (NHIs)**, OAuth/OIDC, workload identity, secrets governance, access reviews, detection, and AI agent authorization.

The goal is to understand how identities that are not humans authenticate, receive authorization, store credentials, access APIs/tools, and get governed over time.

## Scope

This lab covers:

* Non-human identity fundamentals
* OAuth 2.0 / OIDC
* Client Credentials flow
* Okta API Service Apps
* JWT claims and scopes
* Workload identity and federation
* GitHub Actions OIDC
* Cloud IAM patterns
* Secrets and credential lifecycle
* NHI inventory and ownership
* Access reviews
* Detection and abuse patterns
* AI agents as NHIs
* MCP authorization and tool permissions

## Core Model

For every NHI, ask:

```text
What is the identity?
Who owns it?
What credential does it use?
Where is the credential stored?
What access does it have?
Is access scoped?
When was it last used?
Can it be rotated?
Can it be revoked?
Is activity logged?
What is the blast radius if compromised?
```

## Lab Principle

Each lesson maps a technical action to its IAM meaning.

Example:

```text
Create OAuth service app
→ machine identity

Assign scope
→ permission boundary

Request access token
→ authorization artifact

Decode JWT
→ identity/access evidence

Review logs
→ audit trail
```

## Primary Sandbox

Okta is used as the primary IdP sandbox for:

* service apps
* OAuth clients
* client credentials
* scopes
* access tokens
* System Log events
* API access

Concepts are mapped to vendor-neutral NHI patterns and other platforms such as Entra, AWS IAM, GCP IAM, GitHub Actions OIDC, Kubernetes service accounts, Vault, MCP, and AI agent tooling.

## Roadmap

### Week 0: NHI Mental Model

* Human vs non-human identity
* NHI taxonomy
* Authentication methods
* Authorization methods
* Lifecycle differences
* Common failure modes

### Week 1: Okta Service Apps + OAuth Client Credentials

* API Service Apps
* Client ID / client secret
* Client Credentials flow
* Okta API scopes
* Access token request
* Token decoding
* System Log evidence

### Week 2: Tokens, Claims, Scopes, and Audience

* JWT claims
* `iss`, `sub`, `aud`, `exp`, `scp`, `cid`
* Bearer token risk
* Wrong-audience tokens
* Over-scoping
* OAuth errors

### Week 3: CI/CD Workload Identity

* GitHub Actions OIDC
* Federated identity
* Short-lived credentials
* Trust boundaries
* Repository/branch claims

### Week 4: Cloud Workload Identity

* AWS IAM roles
* Azure managed identities
* GCP Workload Identity Federation
* Service principals
* Cross-cloud identity patterns

### Week 5: Secrets and Credential Lifecycle

* Client secrets
* API keys
* PATs
* Private keys
* Secret storage
* Rotation
* Revocation
* Leakage response

### Week 6: NHI Inventory and Ownership

* Discovery
* Ownership mapping
* Business purpose
* Credential age
* Last-used tracking
* Orphaned identities
* Risk scoring

### Week 7: Access Reviews for NHIs

* Access certification
* Review evidence
* Keep / reduce / rotate / revoke decisions
* Exception handling
* Governance packets

### Week 8: Logs, Detection, and Abuse Patterns

* OAuth failures
* Token misuse
* Dormant credential reuse
* Suspicious service app activity
* Write calls from read-oriented identities
* Agent/tool abuse patterns

### Week 9: Advanced OAuth and Client Authentication

* `private_key_jwt`
* mTLS
* DPoP
* Sender-constrained tokens
* Token replay
* Proof-of-possession

### Week 10: AI Agents as NHIs

* Agent identity
* Delegated access
* Tool permissions
* Human approval gates
* Prompt injection as authorization misuse
* Agent audit trails

### Week 11: MCP Authorization

* MCP clients
* MCP servers
* Tools as protected resources
* OAuth for MCP
* Tool-level permissions
* Destructive action controls

### Week 12: Capstone Governance Model

* NHI inventory model
* Credential lifecycle model
* Access review model
* Detection model
* Agent authorization model
* MCP tool governance model

## Months 4-12: Deeper Specialization

After the 12-week foundation, the curriculum continues into specialized tracks:

| Months | Track | Focus |
|--------|-------|-------|
| 4-5 | Advanced OAuth and Token Security | private_key_jwt, mTLS, DPoP, token exchange, token replay, revocation, introspection, OAuth security BCP |
| 5-6 | Cloud and Workload Identity Depth | AWS roles, Azure managed identities, Entra workload identities, GCP WIF, GitHub/GitLab OIDC, Kubernetes service accounts |
| 6-7 | Secrets and Credential Governance | Vault, Infisical, Akeyless, AWS Secrets Manager, Azure Key Vault, dynamic secrets, secret scanning, rotation, incident response |
| 7-8 | NHI Governance Program Design | Inventory, owner mapping, stale access cleanup, access review workflows, exception handling, risk scoring, audit evidence |
| 8-9 | Detection Engineering for NHIs | SIEM logic, CloudTrail/Okta/GitHub logs, anomaly detection, token abuse patterns, dormant key usage, service account lateral movement |
| 9-10 | AI Agents as Governed Identities | Agent identity, delegated access, acting as self vs on behalf of user, human approval, tool scopes, audit trail |
| 10-11 | MCP Authorization and Tool Governance | MCP OAuth, protected resources, tool-level permissions, destructive tool approval, revocation and logging |
| 11-12 | Capstone and Job-Readiness | Portfolio polish, mock interviews, architecture diagrams, open-source templates, public writing |

## Repository Structure

```text
.
├── week0/
├── week1/
├── week2/
├── labs/
│   ├── okta/
│   ├── github-oidc/
│   ├── cloud-workload-identity/
│   └── agent-authz/
├── artifacts/
│   ├── nhi-inventory-template.md
│   ├── token-claims-table.md
│   ├── access-review-template.md
│   ├── credential-lifecycle-checklist.md
│   └── agent-tool-permission-matrix.md
├── diagrams/
└── README.md
```

## Lesson Format

Each lesson includes:

```text
Core concept
Implementation or analysis task
IAM meaning
Failure mode
Artifact
Practice questions
Portfolio note
```

Practice questions are kept separate from answer keys.

## Artifacts

Expected outputs include:

* NHI taxonomy
* Token claims tables
* OAuth flow diagrams
* Scope/access matrices
* NHI inventory templates
* Credential lifecycle checklists
* Access review packets
* Detection notes
* Agent tool permission matrices
* MCP authorization risk maps

## Status

### Foundation (Weeks 0-12)

| Area                            | Status         |
| ------------------------------- | -------------- |
| Week 0: NHI Mental Model        | ✅ Complete    |
| Week 1: Okta OAuth Labs         | ✅ Complete    |
| Week 2: OAuth Client Credentials Deep Dive | ✅ Complete    |
| Week 3: GitHub OIDC             | Not Started    |
| Week 4: Cloud Workload Identity | Not Started    |
| Week 5: Secrets Lifecycle       | Not Started    |
| Week 6: Inventory and Ownership | Not Started    |
| Week 7: Access Reviews          | Not Started    |
| Week 8: Detection               | Not Started    |
| Week 9: Advanced OAuth          | Not Started    |
| Week 10: AI Agents              | Not Started    |
| Week 11: MCP Authorization      | Not Started    |
| Week 12: Capstone               | Not Started    |

### Specialization (Months 4-12)

| Track                              | Status      |
| ---------------------------------- | ----------- |
| Advanced OAuth and Token Security  | Not Started |
| Cloud and Workload Identity Depth  | Not Started |
| Secrets and Credential Governance  | Not Started |
| NHI Governance Program Design      | Not Started |
| Detection Engineering for NHIs     | Not Started |
| AI Agents as Governed Identities   | Not Started |
| MCP Authorization and Tool Gov     | Not Started |
| Capstone and Job-Readiness         | Not Started |

## Focus

This repo is focused on practical IAM engineering for identities that are not humans.

Central question:

```text
How do we govern identities that authenticate and act without a human present?
```
