# Week 2, Day 7: Weekly Synthesis

## Week 2 Summary: OAuth Client Credentials Deep Dive

| Day | Topic | Key Insight |
|-----|-------|-------------|
| 1 | OAuth roles | Client ≠ user. Four distinct roles. |
| 2 | No human user | Client acts as itself, pre-authorized |
| 3 | Client auth methods | private_key_jwt = key never travels |
| 4 | Token endpoint | Every OAuth error tells you what broke |
| 5 | Bearer tokens | Possession = authorization |
| 6 | Lifetime & revocation | JWTs can't be revoked - trade-off |

## Client Credentials Flow Diagram

```
CLIENT                          AUTHORIZATION SERVER
   │                                    │
   │  1. Token Request                  │
   │     grant_type=client_credentials  │
   │     + client authentication        │
   │     + scope                        │
   │───────────────────────────────────▶│
   │                                    │
   │  2. Access Token                   │
   │◀───────────────────────────────────│
   │
   ▼
RESOURCE SERVER
   │
   │  3. API Request + Bearer token
   │───────────────────────────────────▶│
   │                                    │
   │  4. Protected Resource             │
   │◀───────────────────────────────────│

NO RESOURCE OWNER - Client is pre-authorized
```

## Interview Explanation (30 Seconds)

"Client credentials is the OAuth flow for machine-to-machine authentication. There's no human user - the client authenticates directly with the authorization server, receives an access token, and uses it to call APIs. The token is a bearer token, meaning whoever has it can use it. For security, the token has a short lifetime, limited scope, and the client should use asymmetric authentication like private_key_jwt so the secret never travels over the network. In the token, sub equals cid because the app is acting as itself, not on behalf of a user."

## Key Distinctions

| Pattern | Meaning |
|---------|---------|
| sub = cid | NHI / client credentials |
| sub ≠ cid | Human / delegated flow |
| private_key_jwt | Key never sent |
| client_secret_* | Secret travels |
| JWT | Can't be revoked |
| Opaque token | Can be revoked |

## Practice Questions & Answers

**Q1**: Name the four OAuth roles.  
**A1**: Client, Authorization Server, Resource Server, Resource Owner.

**Q2**: Is there a resource owner in client credentials?  
**A2**: No, the client acts as itself, pre-authorized.

**Q3**: Which auth method never sends the secret?  
**A3**: private_key_jwt.

**Q4**: What does "bearer" mean?  
**A4**: Whoever possesses/holds the token can use it.

**Q5**: Can you immediately revoke a JWT?  
**A5**: No, must wait for expiration or use denylist.

**Q6**: sub = cid means what?  
**A6**: NHI/client credentials. If human, sub = user ID, cid = app ID.

## Portfolio Statement

> "I completed a deep dive into OAuth 2.0 client credentials, understanding not just how to get a token but why the protocol works the way it does. I can explain the four OAuth roles, why client credentials has no resource owner, the security differences between authentication methods, and why bearer tokens are both convenient and dangerous. I understand that JWTs can't be revoked because they're self-contained, which is why short lifetimes matter."
