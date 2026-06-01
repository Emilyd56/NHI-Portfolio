# Day 0.5: The Core Idea: Governance Controls and the 17 Master Questions

Governance answers:

```
How do we ensure this identity remains secure, appropriate, and accountable over time?
```

Authentication proves identity. Authorization grants access. Governance ensures that identity and access remain **correct, necessary, and visible** throughout the lifecycle.

The key insight:

```
Technical controls without governance decay.
An identity created correctly today becomes a risk tomorrow without ongoing oversight.
```

---

# 1. The Governance Problem for NHIs

For human identities, governance has natural triggers:

```
Hire         → provision access
Transfer     → modify access
Terminate    → revoke access
Annual review → certify access
```

For NHIs, these triggers don't exist:

```
No hire date
No manager
No HR termination
No one to certify "yes I still need this"
```

The result:

```
NHIs accumulate
Credentials age
Access creeps
Owners leave
Purpose is forgotten
Logs are ignored
```

Governance for NHIs must be **intentionally built**, not assumed.

---

# 2. The Seven Governance Controls

## Control 1: Ownership

```
Every NHI must have an owner.
The owner is accountable for:
  - Purpose justification
  - Access appropriateness
  - Credential rotation
  - Decommissioning when no longer needed
  - Incident response
```

**Failure without it**: Orphaned identities that no one rotates, reviews, or removes.

---

## Control 2: Purpose Documentation

```
Every NHI must have a documented purpose.
  - What does it do?
  - What systems does it access?
  - Why does it need this access?
```

**Failure without it**: Cannot determine if access is appropriate or excessive.

---

## Control 3: Scope Limitation

```
Every NHI should have minimum necessary access.
  - Read when read is enough
  - Scoped to specific resources, not wildcards
  - Time-bound if possible
```

**Failure without it**: Over-privileged identities with large blast radius.

---

## Control 4: Credential Rotation

```
Every credential must have a rotation policy.
  - Secrets: 90 days or less
  - Certificates: before expiration
  - Keys: per policy or on compromise
  - Federated tokens: automatic (minutes)
```

**Failure without it**: Long-lived credentials that may already be compromised.

---

## Control 5: Activity Logging

```
Every NHI's actions must be logged.
  - Authentication events
  - API calls
  - Scope/permission usage
  - Errors and denials
```

**Failure without it**: No evidence for detection, investigation, or review.

---

## Control 6: Access Review

```
Every NHI's access must be periodically reviewed.
  - Is the identity still needed?
  - Is the access still appropriate?
  - Is the owner still correct?
  - Has activity occurred recently?
```

**Failure without it**: Stale access accumulates indefinitely.

---

## Control 7: Revocation Capability

```
Every NHI must be revocable.
  - Can we disable the identity?
  - Can we revoke the credential?
  - Can we invalidate active tokens?
  - How quickly?
```

**Failure without it**: Cannot respond to compromise or misuse.

---

# 3. The 17 Master Questions

These questions apply to **every NHI, on every platform, in every context**.

Memorize them. Apply them. They are your portable governance framework.

```
IDENTITY
1.  What is the identity?
2.  Is it human or non-human?
3.  What NHI type is it? (OAuth client, service account, CI/CD, workload, secret-bearer, agent)

OWNERSHIP
4.  Who owns it?
5.  What is its purpose?
6.  Is the owner still valid? (Did they leave? Change roles?)

CREDENTIALS
7.  What credential does it use?
8.  Where is the credential stored?
9.  How old is the credential?
10. Can it be rotated?
11. Can it be revoked?

ACCESS
12. What access does it have?
13. Is access temporary or long-lived?
14. Is access least-privilege?

VISIBILITY
15. Is activity logged?
16. When was it last used?

RISK
17. What happens if it is compromised? (Blast radius)
```

---

# 4. Applying the 17 Questions: Example

**Scenario**: A GitHub PAT was created 18 months ago by a developer who left 6 months ago. It has `repo` scope and is stored in a CI/CD environment variable.

```
1.  What is the identity?           → GitHub PAT
2.  Is it human or non-human?       → Non-human (used by CI/CD)
3.  What NHI type?                  → Secret-bearing app + CI/CD identity
4.  Who owns it?                    → Unknown (creator left)
5.  What is its purpose?            → CI/CD repo access (assumed)
6.  Is owner still valid?           → No - orphaned
7.  What credential?                → PAT (bearer token)
8.  Where stored?                   → CI/CD environment variable
9.  How old?                        → 18 months
10. Can it be rotated?              → Yes, but no one is doing it
11. Can it be revoked?              → Yes
12. What access?                    → Full repo access (read/write)
13. Temporary or long-lived?        → Long-lived (no expiration set)
14. Least-privilege?                → No - `repo` is broad
15. Is activity logged?             → Partially (GitHub audit log)
16. When last used?                 → Unknown without audit log review
17. Blast radius?                   → Full repo compromise, code injection, secret exposure
```

**Verdict**: High-risk orphaned NHI. Immediate action: revoke, create new PAT with owner, narrower scope, and rotation policy.

---

# 5. The NHI Governance Lifecycle

```
┌─────────────────────────────────────────────────────────────────┐
│                        NHI GOVERNANCE                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   CREATE          OPERATE           REVIEW          RETIRE      │
│   ──────          ───────           ──────          ──────      │
│   • Assign owner  • Log activity    • Certify need  • Revoke    │
│   • Document      • Rotate creds    • Verify owner  • Disable   │
│     purpose       • Monitor usage   • Check scope   • Archive   │
│   • Limit scope   • Detect anomaly  • Confirm use   • Document  │
│   • Issue creds                                                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

# 6. NHI Glossary

| Term | Definition |
|------|------------|
| **Non-human identity (NHI)** | Digital identity used by system, app, automation, workload, or agent |
| **OAuth client / service app** | Application registered with IdP to request tokens via OAuth flows |
| **Service account** | Named account for a system, not tied to OAuth |
| **CI/CD identity** | Identity used by build/deploy pipelines |
| **Cloud workload identity** | Identity assigned to compute in cloud (role, managed identity) |
| **Secret-bearing app** | Application holding static credential (API key, PAT, secret) |
| **AI agent / MCP client** | AI system calling APIs or tools |
| **Client secret** | Static shared secret for OAuth client authentication |
| **API key** | Static bearer token granting access when presented |
| **Private key JWT** | Asymmetric client authentication using signed JWT assertion |
| **OIDC federation** | Short-lived token from trusted IdP, validated by claims |
| **mTLS** | Mutual TLS authentication using client certificates |
| **SPIFFE/SPIRE** | Workload attestation system issuing short-lived SVIDs |
| **OAuth scope** | Permission boundary granted at token issuance |
| **Cloud IAM policy** | Resource-based permission policy in cloud platforms |
| **Delegated permission** | App acts on behalf of user, limited by both |
| **Application permission** | App acts as itself, access to all data in scope |
| **Blast radius** | Scope of damage if identity is compromised |
| **Orphaned identity** | NHI with no valid owner |
| **Stale credential** | Credential that hasn't been rotated per policy |
| **Access review** | Periodic certification that access is still appropriate |

---

# 7. Practice Questions

**Q1**: An OAuth client was created 2 years ago. The developer who created it is still at the company but moved to a different team. Is this NHI orphaned?

**A1**: Effectively orphaned - the developer likely isn't managing it anymore. Technically the person exists, but ownership should transfer when team changes. This is a governance failure requiring ownership transfer.

**Q2**: A service account has `admin` access but logs show it only uses `read` operations. What governance action is appropriate?

**A2**: Reduce access to read-only. Over-privileged based on actual usage - apply least privilege.

**Q3**: A CI/CD pipeline uses OIDC federation to assume a cloud role. The token expires in 15 minutes. Does this need credential rotation?

**A3**: No. Tokens are ephemeral by design - no static credential to rotate.

**Q4**: An API key is stored in a secrets manager, rotated every 90 days, with access logged. Is this a well-governed secret?

**A4**: Yes - covers storage, rotation, and logging. Add documented owner and purpose for full governance.

**Q5**: Which of the 17 questions directly determines blast radius?

**A5**: Q17: "What happens if it is compromised?" Other questions (Q12 access, Q13 lifetime, Q14 least-privilege) contribute but Q17 is direct.

**Q6**: An access review reveals an NHI that hasn't been used in 14 months. What are the possible actions?

**A6**: 1) Investigate - verify truly unused. 2) Contact owner - confirm if needed. 3) Disable temporarily - wait for complaints. 4) Revoke/retire/decommission - permanent removal if unneeded.

---

# 8. Day 0.5 Output

By the end of Day 0.5, you should have:

```
1. Understanding of 7 governance controls
2. Memorization of 17 master questions
3. Ability to apply questions to any NHI scenario
4. Artifact created: week0/day5-governance-masterquestions.md
5. Practice questions answered
```

---

# 9. Week 0 Completion

After Day 0.5, you have completed the **vendor-neutral NHI mental model**.

```
Week 0 Artifacts:
├── day1-human-vs-nhi.md
├── day2-nhi-taxonomy.md
├── day3-authn-methods.md
├── day4-authz-methods.md
└── day5-governance-masterquestions.md
```

**Next week**: Week 1 - Okta Service Apps + OAuth Client Credentials (hands-on implementation begins)
