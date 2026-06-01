# Day 0.4: The Core Idea: Authorization Methods for NHIs

Authentication answers: "Who is this?"

Authorization answers:

```
What is this identity allowed to do?
```

For NHIs, authorization defines the **blast radius** - how much damage can occur if the identity is compromised or misused.

The key insight:

```
Least privilege is harder for machines than humans.
Machines don't complain when they lack access.
So they often get more than they need "just in case."
```

---

# 1. The Authorization Methods

## Method 1: OAuth Scopes (Consent-Based Boundary)

```
What it is:    Permission boundaries requested at token issuance
How it works:  Client requests scopes; authorization server issues token with granted scopes
Examples:      Okta scopes (okta.users.read), GitHub OAuth scopes (repo, read:user), Google API scopes
```

**How it limits access:**

```
Token only grants access to resources covered by the scope
Resource server validates scope in token before allowing action
```

**IAM pattern:**

```
read scope    → can retrieve data
write scope   → can create/modify data
admin scope   → can manage configuration, users, or the resource itself
```

---

## Method 2: Cloud IAM Roles/Policies (Resource-Based Boundary)

```
What it is:    Policies attached to identities or resources defining allowed actions
How it works:  Identity assumes role or has attached policy; cloud evaluates policy on each API call
Examples:      AWS IAM policies, Azure RBAC roles, GCP IAM roles
```

**How it limits access:**

```
Policy specifies: which actions, on which resources, under which conditions
Deny by default: anything not explicitly allowed is denied
```

**IAM pattern:**

```
Action:   s3:GetObject, ec2:StartInstances, secretsmanager:GetSecretValue
Resource: arn:aws:s3:::bucket-name/*, specific EC2 instance ARN
Condition: source IP, time of day, MFA present, requesting principal
```

---

## Method 3: API Permissions (Endpoint-Based Boundary)

```
What it is:    Permissions granted to access specific API endpoints or operations
How it works:  Application is granted permission to call certain APIs; platform enforces at runtime
Examples:      Microsoft Graph API permissions, Salesforce connected app permissions, Slack app scopes
```

**How it limits access:**

```
App can only call APIs it has permission for
Permissions may be "delegated" (on behalf of user) or "application" (as itself)
```

**IAM pattern:**

```
Delegated:    App acts with user's permissions, limited by both app AND user access
Application:  App acts as itself, no user context, full app permissions apply
```

---

## Method 4: Tool Permissions / MCP Scopes (Action-Based Boundary)

```
What it is:    Permissions defining which tools or actions an agent can invoke
How it works:  Agent requests tool access; authorization layer validates before execution
Examples:      MCP tool permissions, AI agent capability grants, function-calling restrictions
```

**How it limits access:**

```
read tools:       Agent can query/retrieve information
write tools:      Agent can create or modify data
destructive tools: Agent can delete, terminate, or make irreversible changes
```

**IAM pattern:**

```
Tool: read_ticket      → Low risk
Tool: create_ticket    → Medium risk (can spam, pollute data)
Tool: delete_ticket    → High risk (irreversible, needs approval gate)
Tool: execute_command  → Critical risk (arbitrary code execution)
```

---

# 2. Read vs Write vs Admin

Every authorization system has some version of this hierarchy:

```
Read      → retrieve, list, view, get
Write     → create, update, modify, put
Admin     → delete, manage, configure, grant permissions
```

Mapping across systems:

| Level | OAuth Scope Example | AWS IAM Example | MCP Tool Example |
|-------|---------------------|-----------------|------------------|
| Read | `okta.users.read` | `s3:GetObject` | `read_ticket` |
| Write | `okta.users.manage` | `s3:PutObject` | `create_ticket` |
| Admin | `okta.apps.manage` | `s3:DeleteBucket`, `iam:*` | `delete_ticket` |

**Key risk**: "Read" is not harmless.

```
Read access enables:
- Data exfiltration
- Enumeration (discovering what exists)
- Reconnaissance for later attacks
- Privacy violations
```

---

# 3. Least Privilege for Machines

For humans, least privilege is enforced through:

```
Access requests
Manager approvals
Access reviews
Complaints when access is missing ("I can't do my job")
```

For machines, least privilege fails because:

```
No one requests - developer provisions what seems needed
No one approves - access is set at deploy time
No one reviews - machine access is invisible until audit
No complaints - machine silently fails or developer over-provisions "to be safe"
```

The result:

```
Machines often have more access than they need
Over-provisioning is the default
Access creep is invisible
```

---

# 4. Cross-Platform Authorization Mapping

| Concept | Okta | AWS | Azure | MCP/Agents |
|---------|------|-----|-------|------------|
| Permission boundary | OAuth scope | IAM policy | RBAC role | Tool permission |
| Read access | `*.read` scope | `Get*`, `List*`, `Describe*` | Reader role | read tools |
| Write access | `*.manage` scope | `Put*`, `Create*`, `Update*` | Contributor role | write tools |
| Admin access | admin scopes | `Delete*`, `iam:*` | Owner role | destructive tools |
| Delegation | Delegated permission | AssumeRole, cross-account | Managed identity | on-behalf-of token |

---

# 5. Failure Modes

**Over-scoped OAuth client**

```
Result: Token has admin scopes when only read was needed
Risk: Compromised token can modify or delete, not just read
```

**Wildcard IAM policies**

```
Example: "Action": "*", "Resource": "*"
Result: Identity can do anything to everything
Risk: Single compromise = full account takeover
```

**Delegated vs application permissions confused**

```
Result: App gets application-level permissions when delegated was intended
Risk: App can access all users' data, not just the consenting user's
```

**No tool-level authorization for agents**

```
Result: Agent can call any tool - read, write, delete
Risk: Prompt injection leads to destructive action; no approval gate
```

**Read access treated as safe**

```
Result: Broad read access granted without review
Risk: Data exfiltration, enumeration, privacy breach
```

---

# 6. Practice Questions

**Q1**: An Okta service app has the scope `okta.users.manage`. Can it read users, create users, or both?

**A1**: Both. "Manage" scopes typically include read + write + admin operations.

**Q2**: An AWS Lambda function has this policy: `"Action": "s3:*", "Resource": "*"`. What's the authorization risk?

**A2**: Identity can do anything to everything in S3. Wildcard action + wildcard resource = full access including delete.

**Q3**: A Microsoft Graph app has "Application" permissions for `Mail.Read`. Does it read mail for one user or all users?

**A3**: All users in the tenant. Application permissions apply tenant-wide, not per-user.

**Q4**: An AI agent can call these MCP tools: `read_ticket`, `create_ticket`, `delete_ticket`. Which tool should require a human approval gate?

**A4**: `delete_ticket` - destructive, irreversible action.

**Q5**: A CI/CD pipeline has read-only access to production secrets. Is this safe?

**A5**: No. Read access to secrets = exfiltration risk. "Read-only" sounds safe but isn't for sensitive data.

**Q6**: What's the difference between delegated and application permissions?

**A6**: Delegated = app acts on behalf of a user (limited by both app AND user access). Application = app acts as itself (access to ALL data in permission scope).

---

# 7. Day 0.4 Output

By the end of Day 0.4, you should have:

```
1. Understanding of 4 authorization methods across platforms
2. Ability to map read/write/admin across OAuth, IAM, and MCP
3. Artifact created: week0/day4-authz-methods.md
4. Practice questions answered
```
