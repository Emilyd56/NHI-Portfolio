# Week 2, Day 6: Token Lifetime, Replay Risk, and Revocation Limits

## Core Concept

Tokens have three temporal properties:
- **Lifetime** - How long the token is valid
- **Replay risk** - Can a captured token be reused?
- **Revocation** - Can you kill it before expiration?

## Token Lifetime Trade-Off

| Lifetime | Attack Window | Token Requests | Incident Response |
|----------|---------------|----------------|-------------------|
| Short (minutes) | Small | Frequent | Fast recovery |
| Long (hours/days) | Large | Infrequent | Slow recovery |

## The JWT Revocation Problem

JWTs are **self-contained**. The token carries everything needed to validate it.

The resource server:
1. Checks signature
2. Checks expiration
3. Checks audience/issuer

It does NOT call the auth server to verify validity.

**Result**: If a JWT is compromised, you cannot immediately revoke it. You must wait for expiration or implement a denylist.

## The Architectural Trade-Off

| Aspect | JWT (Self-Contained) | Opaque Token (Server-Checked) |
|--------|---------------------|------------------------------|
| Performance | Fast - no lookup | Slower - requires lookup |
| Scalability | Better - no central state | Harder - bottleneck |
| Revocation | Hard - wait for exp | Easy - delete from DB |
| Compromise impact | Bad until expiration | Can stop immediately |

**Key insight**: JWTs trade revocation capability for performance and scalability.

## Revoking Client vs Revoking Token

| Action | Effect |
|--------|--------|
| Revoke client | Stops NEW tokens; existing tokens still work |
| Revoke token (JWT) | Not feasible; wait for expiration or denylist |

## Practice Questions

**Q1**: Token stolen at minute 1 of 1-hour lifetime. How long does attacker have?  
**A1**: 59 minutes.

**Q2**: Can you revoke a JWT access token immediately?  
**A2**: No. JWTs are self-contained. Must wait for expiration or use denylist.

**Q3**: Difference between revoking client vs revoking token?  
**A3**: Client revocation stops new tokens; existing tokens work until expiration. Token revocation isn't feasible for JWTs.

**Q4**: Why are refresh tokens easier to revoke?  
**A4**: Stored server-side, validity checked on each use.

**Q5**: Faster incident response = longer or shorter token lifetime?  
**A5**: Shorter.

## IAM Meaning

Token lifetime is a security control. The question to ask: "If this token leaked right now, how long until it naturally expires?" That's the minimum time an attacker has.
