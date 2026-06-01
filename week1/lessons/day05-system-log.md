# Week 1, Day 5: System Log and Audit Evidence

---

## 1. The Core Idea

Governance requires proof. When someone asks "what did that service app do?" or "was that API accessed last night?" - you need evidence.

In Okta, the **System Log** is where all identity events leave traces. Every token request, every API call, every authentication attempt - logged.

For NHIs, System Log answers the questions you can't answer by asking the machine: "What have you been doing?"

---

## 2. What Okta Logs for Service Apps

| Event Type | What It Captures |
|------------|------------------|
| `app.oauth2.token.grant` | Token issued |
| `app.oauth2.token.grant.refresh` | Token refreshed |
| `app.oauth2.as.authorize` | Authorization request |
| `app.oauth2.as.token.revoke` | Token revoked |
| `app.oauth2.client.authentication` | Client auth attempt |
| `system.api_token.use` | API token used |

Each event contains:
- **Actor**: Who/what did it (client ID for service apps)
- **Target**: What was affected
- **Outcome**: Success or failure
- **Timestamp**: When it happened
- **Client IP**: Where the request came from

---

## 3. Key Search Queries

**Find all token grants:**
```
eventType eq "app.oauth2.token.grant"
```

**Find activity by a specific client:**
```
actor.id eq "0oady8o80iaVwAD1x0x7"
```

**Find failures:**
```
outcome.result eq "FAILURE"
```

**Combine filters:**
```
outcome.result eq "FAILURE" AND actor.id eq "0oady8o80iaVwAD1x0x7"
```

---

## 4. Anatomy of a Log Event

| Field | What It Contains |
|-------|------------------|
| eventType | Type of event (e.g., app.oauth2.token.grant) |
| displayMessage | Human-readable description |
| outcome.result | SUCCESS or FAILURE |
| published | Timestamp |
| actor.id | Client ID or "unknown client" if auth failed |
| actor.type | Type of identity |
| client.ipAddress | Source IP |
| target | What was affected |

**Key insight**: When actor is "unknown client", authentication failed before identity could be established. No attribution possible.

---

## 5. Evidence Trail Questions

| Question | How to Find Answer |
|----------|-------------------|
| Has this app ever been used? | Any events with this actor.id |
| When was it last used? | Most recent event timestamp |
| Has it failed authentication? | outcome.result = FAILURE events |
| What scopes did it request? | Token grant event details |
| From what IP address? | client.ipAddress field |

---

## 6. Suspicious Patterns

| Pattern | Risk |
|---------|------|
| Token requests at unusual hours | Activity outside expected schedule |
| Multiple failures then success | Credential guessing |
| New/unknown IP address | Credential may have leaked |
| Spike in requests | Automation issue or abuse |
| Activity after decommissioning | Orphaned app still in use |

---

## 7. Vendor-Neutral Mapping

| Okta | Portable Pattern |
|------|------------------|
| System Log | Identity audit log |
| Event types | Audit event taxonomy |
| Actor | Identity that performed action |
| Target | Resource affected |
| Outcome | Success/failure evidence |

---

## 8. Outside-Okta Mapping

| Concept | Okta | Entra ID | AWS | Google Cloud |
|---------|------|----------|-----|--------------|
| Audit log | System Log | Entra audit logs | CloudTrail | Cloud Audit Logs |
| Token events | app.oauth2.* | Sign-in logs | STS events | Token events |

---

## 9. Practice Questions & Answers

**Q1**: What Okta event type shows a service app got a token?
> `app.oauth2.token.grant`

**Q2**: To find all activity by your service app, what field do you filter on?
> actor.id

**Q3**: Your service app hasn't been used in 6 months. How would you verify?
> Filter by actor.id and check the most recent event timestamp.

**Q4**: Token grant from unfamiliar IP - what's the risk?
> Credential may have been copied or leaked to another machine.

**Q5**: Difference between actor and target?
> Actor = who performed the action. Target = what was affected.
