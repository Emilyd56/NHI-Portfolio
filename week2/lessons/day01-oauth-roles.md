# Week 2, Day 1: OAuth Roles

---

## 1. The Core Idea

OAuth 2.0 has four distinct roles that interact to make authorization happen. Understanding these roles is how you stop seeing OAuth as magic and start seeing it as a system with clear responsibilities.

---

## 2. The Four Roles

| Role | Question It Answers |
|------|---------------------|
| Resource Owner | Who owns the data/resource? |
| Client | Who wants access? |
| Authorization Server | Who decides if access is granted? |
| Resource Server | Who has the data and enforces access? |

---

## 3. Role Definitions

### Resource Owner
The entity that owns the protected resource and can grant access to it.
- **Human flows**: The user
- **Client credentials (NHI)**: None - client is pre-authorized

### Client
The application requesting access to a protected resource.
- NOT the user - the application
- For NHIs: the service app / machine identity

### Authorization Server
The server that authenticates the client, validates the request, and issues tokens.
- Verifies client identity
- Checks allowed scopes
- Issues access tokens

### Resource Server
The server that holds the protected resource and accepts/rejects access tokens.
- Validates tokens (signature, expiration, audience, scopes)
- Returns resource if valid, rejects if not

---

## 4. Client Credentials Flow Diagram

```
┌──────────┐                    ┌─────────────────────┐
│  CLIENT  │───── request ─────▶│ AUTHORIZATION SERVER│
│          │      token         │                     │
│          │◀──── access ───────│                     │
│          │      token         │                     │
└──────────┘                    └─────────────────────┘
      │
      │ use token
      ▼
┌─────────────────────┐
│   RESOURCE SERVER   │
│                     │
│   validates token   │
│   returns resource  │
└─────────────────────┘
```

No resource owner in client credentials flow - client is pre-authorized.

---

## 5. Week 1 Lab Mapped to Roles

| Role | What Played That Role |
|------|----------------------|
| Client | nhi-lab-day1 service app |
| Authorization Server | org1-pro-7fe0e.oktapreview.com/oauth2/v1/token |
| Resource Server | org1-pro-7fe0e.oktapreview.com/api/v1/users |
| Resource Owner | None (client credentials flow) |

---

## 6. Why This Matters for NHIs

In human flows:
- Resource owner provides consent at runtime
- User sees consent screen and clicks "Allow"

In client credentials (NHI) flows:
- No human to consent
- Authorization is pre-configured by an admin
- Client acts on its own behalf, not on behalf of a user
- This is why `sub` = `cid` in the token

**IAM implication**: NHIs get authorization at setup time, not runtime.

---

## 7. Common Confusion

| Confusion | Clarification |
|-----------|---------------|
| "Client means user" | Client = application. User = resource owner. |
| "Auth server and resource server are the same" | Sometimes yes, sometimes no. |
| "Resource owner approves every request" | Only in human flows. NHIs are pre-authorized. |

---

## 8. Vendor-Neutral Mapping

| Role | Okta | Entra ID | Auth0 | AWS |
|------|------|----------|-------|-----|
| Authorization Server | Okta org | Microsoft identity platform | Auth0 tenant | Cognito / STS |
| Resource Server | Okta API | Microsoft Graph | Your API | AWS services |
| Client | Service app | App registration | M2M application | IAM role/user |

---

## 9. Practice Questions & Answers

1. What OAuth role does your service app play? → **Client**
2. What role issues access tokens? → **Authorization Server**
3. What role validates tokens and returns data? → **Resource Server**
4. Is there a resource owner in client credentials flow? → **No, client is pre-authorized**
5. Why is authorization pre-configured for NHIs? → **No human in the loop, client acts on its own behalf**
