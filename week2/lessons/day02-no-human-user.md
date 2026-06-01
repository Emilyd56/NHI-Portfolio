# Week 2, Day 2: Why Client Credentials Has No Human User

---

## 1. The Core Idea

The client credentials grant has no human user involved. The client authenticates and acts entirely on its own behalf. This is by design - some workloads don't represent a human.

---

## 2. "Acting On Its Own Behalf"

- The client is not representing a user
- The client is not limited by a user's permissions
- The client's access is whatever scopes were granted to the app itself
- All actions are attributed to the client, not to any human

This is **application permission**, not **delegated permission**.

---

## 3. Client Credentials Flow

```
Service app sends credentials → Okta validates → token issued

No user. No redirect. No consent screen. No password.

Token contains: sub = client ID, cid = client ID
```

---

## 4. Hands-On Verification

### Service App Configuration
- App type: Service
- Grant type: Client acting on behalf of itself
- User assignment tab: Does not exist
- Scopes: Pre-configured in Okta API Scopes by admin

### Token Claims
- No `name` claim (user profile)
- No `email` claim (user profile)
- No `groups` claim (user group membership)
- `sub` = `cid` = client ID

---

## 5. Why No Human?

| Scenario | Why No Human |
|----------|--------------|
| Nightly batch job | Runs at 2am, no one logged in |
| Backend service calling another service | Machine-to-machine |
| CI/CD pipeline | Automated |
| Monitoring system | Always running |

---

## 6. IAM Implication

| Human Flow | NHI Flow |
|------------|----------|
| User consents at runtime | Admin configures at setup time |
| Access limited by user + app | Access limited by app only |
| Audit shows user took action | Audit shows app took action |
| User leaves → access revoked via user lifecycle | No user lifecycle - must manage app lifecycle separately |

**Key insight**: No user means no user lifecycle triggers. NHI governance must be intentional.

---

## 7. Practice Questions & Answers

1. Who provides consent in client credentials flow? → **Admin pre-configures it**
2. Token has `sub` = `0oady8o80iaVwAD1x0x7`. User ID? → **No, client ID**
3. Does service app have user assignment tab? → **No**
4. Why no `email` or `name` claims? → **Those are user profile claims, not applicable to NHIs**
5. Nightly batch job - which flow? → **Client credentials**
