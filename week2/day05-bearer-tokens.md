# Week 2, Day 5: Bearer Tokens and Why Stolen Tokens Are Dangerous

## Core Concept

The access token is a **bearer token**. "Bearer" means whoever holds the token can use it - no additional proof of identity required.

## Key Points

### What "Bearer" Means
- Whoever possesses the token can use it
- The API doesn't ask "are you really the client?"
- It only asks "do you have a valid token?"

### If an Attacker Steals Your Token

| Action | Result |
|--------|--------|
| Call the API | Succeeds |
| Read data | Succeeds |
| Be identified as your app | Yes |
| Appear in audit logs | As your app, not attacker |

The attacker **becomes your app** for the token's lifetime.

### How Tokens Get Stolen
- Log exposure
- Network interception
- Memory dumps
- Accidental commits
- Insider threats
- Malware

### What Limits the Damage

| Protection | What It Limits |
|------------|----------------|
| Scope | WHAT attacker can do |
| Lifetime | HOW LONG they can do it |
| Audience | WHICH APIs accept the token |

## The Fundamental Problem

**Possession = Authorization**

No second factor. No "prove you're the real client." Just: do you have the token?

## Stronger Alternatives

| Mechanism | How It Helps |
|-----------|--------------|
| DPoP | Token bound to key - must prove key possession |
| mTLS binding | Token bound to client certificate |

## Practice Questions

**Q1**: What does "bearer" mean in the context of access tokens?  
**A1**: Whoever carries/possesses the token can use it. Identity is attached to possession.

**Q2**: If an attacker steals your access token, what can they do?  
**A2**: Call the API, read data, be identified as your app, appear in logs as your app.

**Q3**: What's the main built-in protection for bearer tokens?  
**A3**: Expiration.

**Q4**: Why does token lifetime matter for security?  
**A4**: Shorter lifetime = smaller attack window for stolen tokens.

**Q5**: In audit logs, would a stolen token appear as the attacker or as your app?  
**A5**: As your app.

## IAM Meaning

Bearer tokens create a fundamental security trade-off: convenience vs proof of possession. When doing access reviews or incident response, ask:
- Where is this token stored?
- How is it transmitted?
- What's the lifetime?
- If this token leaked right now, what could an attacker do?

## Vendor-Neutral Pattern

This applies to all OAuth 2.0 implementations: Okta, Entra, Auth0, AWS Cognito, etc. Bearer tokens are the default, and their risks are universal.
