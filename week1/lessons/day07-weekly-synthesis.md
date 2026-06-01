# Week 1, Day 7: Weekly Synthesis

---

## What Was Built

```
Service App:    nhi-lab-day1
Client ID:      0oady8o80iaVwAD1x0x7
Auth method:    private_key_jwt (RSA-2256)
Scope:          okta.users.read
Outcome:        Token obtained, API called, evidence logged
```

---

## What Was Learned

### Day 1: Service App + Token Request
- Created an OAuth service app as an NHI
- Used private_key_jwt authentication (asymmetric proof)
- Built a signed JWT assertion and exchanged it for an access token
- Called the Okta Users API with the token
- Applied the 17 governance questions

### Day 2: Token Claims
- The 8 core claims: iss, sub, aud, cid, scp, iat, exp, jti
- `sub` = `cid` means app acting as itself (application permission)
- `aud` prevents token reuse across APIs
- Scope levels: read < write < manage < admin

### Day 5: System Log
- How to search for token grants: `eventType eq "app.oauth2.token.grant"`
- How to filter by your app: `actor.id eq "<client_id>"`
- "Unknown client" = auth failed before identity established
- Troubleshooting left 23 audit events as evidence

---

## Key Concepts Mastered

| Concept | Definition |
|---------|------------|
| Service app | OAuth client representing a machine, not a human |
| private_key_jwt | Asymmetric auth where private key never leaves your machine |
| Access token | Time-bound authorization artifact with claims |
| `sub` = `cid` | Signature of application permission (app as itself) |
| Audience (`aud`) | Security boundary preventing token reuse |
| System Log | Evidence trail for all NHI activity |
| Actor (log field) | The identity that performed a logged action |
| Subject (token claim) | The identity the token represents |

---

## Quiz Results

| Q | Question | Answer |
|---|----------|--------|
| 1 | Claim for who token represents | `sub` (subject) |
| 2 | What `sub` = `cid` means | App acting as itself, application permissions |
| 3 | Event type for token grants | `eventType eq "app.oauth2.token.grant"` |
| 4 | Does private key auto-expire? | No, must be manually rotated |
| 5 | Where to find NHI activity evidence | Reports → System Log |

**Score: 4.5/5**

---

## Portfolio Seed

> "I built my first non-human identity by creating an Okta API Service app using OAuth 2.0 client credentials with private_key_jwt authentication. I generated an RSA key pair, constructed signed JWT assertions, and exchanged them for scoped access tokens. The token's claims - particularly `sub` equaling `cid` - confirmed this was application permission, not delegated access. I verified the NHI's activity in Okta's System Log, finding 23 audit events from my session. This hands-on work taught me how machine identities authenticate, receive scoped authorization, and leave audit evidence."

---

## Week 1 Complete

Artifacts produced:
- `week1/day1-okta-service-app.md`
- `week1/day2-token-claims.md`
- `week1/day5-system-log.md`
- `week1/day7-weekly-synthesis.md`

Next: Week 2 - OAuth Client Credentials Deep Dive
