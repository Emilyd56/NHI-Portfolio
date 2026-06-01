# Day 0.1: The Core Idea: Human vs Non-Human Identity

An **identity** in IAM is the answer to:

```
Who or what is making this request?
```

It is not a username. It is not a password. It is the entity that authenticates and receives authorization.

Identities split into two categories:

```
Human identity    → represents a person
Non-human identity → represents a system, app, automation, workload, or agent
```

This distinction matters because the **lifecycle, credential type, and governance model** are fundamentally different.

---

# 1. Why NHIs Exist

Humans cannot be present for every operation.

```
A nightly sync job runs at 3am
A CI/CD pipeline deploys code on merge
A backend service calls another service
An AI agent reads tickets and drafts responses
A monitoring system polls health endpoints
```

Each of these needs an identity to authenticate. None of them involve a human typing a password at runtime.

That identity is a non-human identity.

---

# 2. The Population Problem

In most enterprises:

```
Human identities:     5,000
Non-human identities: 50,000 - 250,000
```

The ratio is often 10x to 50x.

NHIs include:

```
Service accounts
OAuth clients / service apps
CI/CD runners and workflows
Cloud workload identities (roles, managed identities)
API keys and PATs
Bots and automation accounts
AI agents and MCP clients
```

If you only govern human identities, you govern 2-10% of your identity surface.

---

# 3. Five Lifecycle Differences

| Attribute | Human Identity | Non-Human Identity |
|-----------|---------------|-------------------|
| **Lifecycle trigger** | HR events (hire, transfer, terminate) | System events (deploy, decommission) - often missed |
| **Credential reset** | User-initiated ("forgot password") | Operator-initiated (rotation policy) - often skipped |
| **MFA protection** | Yes | Rarely possible - no human to approve |
| **Dormancy signal** | Last login | Last API call - often not tracked |
| **Owner** | The person themselves | Someone else - often unclear or outdated |

The core problem:

```
Human offboarding is triggered by HR.
NHI offboarding is triggered by... nothing, unless you build it.
```

---

# 4. IAM Meaning

When you encounter any identity, ask:

```
Is this human or non-human?
```

If non-human:

```
Who owns it?
What credential does it use?
Where is that credential stored?
What access does it have?
When was it last used?
Can it be rotated and revoked?
Is its activity logged?
What happens if it's compromised?
```

These questions apply regardless of vendor. Okta, Entra, AWS, GitHub, Kubernetes - the questions stay the same.

---

# 5. Failure Modes

**No owner assigned**

```
Result: No one rotates credentials, reviews access, or decommissions it
Risk: Orphaned identity with stale, valid credentials
```

**Treated like a human**

```
Result: Waiting for HR offboarding that never comes
Risk: Identity persists indefinitely after its purpose ends
```

**Shared credentials**

```
Result: Multiple systems use the same secret
Risk: Cannot revoke one without breaking others; no attribution in logs
```

**Over-privileged**

```
Result: App only needs read access but has admin
Risk: Breach = full compromise, not contained incident
```

**No last-used tracking**

```
Result: Cannot identify dormant NHIs
Risk: 18-month-old unused credential is still valid attack surface
```

---

# 6. Practice Questions

**Q1**: A CI/CD pipeline uses a static API key stored in environment variables to deploy to production. Is this a human or non-human identity?

**A1**: Non-human. No person authenticates at runtime.

**Q2**: Why doesn't HR offboarding work for NHIs?

**A2**: HR offboarding is triggered by employment status. NHIs are not employees. No HR event means no automatic deprovisioning.

**Q3**: A service account was created 3 years ago. The developer who created it left 2 years ago. The account still has admin access and valid credentials. What is the IAM risk?

**A3**: Orphaned identity. No owner to rotate, review, or decommission. Valid credentials with excessive access and no accountability.

**Q4**: An organization has 8,000 employees and 120,000 service accounts. Is this ratio unusual?

**A4**: No. 15x is within the typical 10-50x range.

**Q5**: What makes non-human identity governance harder than human identity governance?

**A5**: No natural lifecycle triggers. No MFA. No self-service password reset. No HR-driven offboarding. Ownership often unclear. Credentials often long-lived and forgotten.

---

# 7. Portfolio Seed

> "Non-human identities require different governance than human identities because they lack natural lifecycle triggers. There's no HR termination, no MFA challenge, no password reset request. If you don't build intentional controls - ownership, rotation, last-used tracking, access reviews, decommissioning workflows - NHIs become long-lived, over-privileged attack surfaces that no one monitors."

---

# 8. Day 0.1 Output

By the end of Day 0.1, you should have:

```
1. Understanding of human vs non-human identity distinction
2. Five lifecycle differences memorized
3. Artifact created: week0/day1-human-vs-nhi.md
4. Practice questions answered
5. Portfolio seed saved
```
