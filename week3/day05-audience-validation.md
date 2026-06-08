# Week 3, Day 5: Audience Validation - Why APIs Should Reject Wrong-Audience Tokens

**Date**: June 7, 2026  
**Quiz Score**: 5/5

---

## 1. Core Idea

The **audience** (`aud`) claim tells the API: "This token was issued for YOU."

If an API doesn't validate audience, it might accept tokens meant for a completely different API - a vulnerability called the **confused deputy problem**.

---

## 2. Concept Breakdown

### What Audience Means

| Claim | Question It Answers |
|-------|---------------------|
| `sub` | WHO is this token about? |
| `scp` | WHAT can they do? |
| `aud` | WHERE can this token be used? |

### The Confused Deputy Problem

Without audience validation, an attacker with a low-privilege API token could send it to a high-privilege API that trusts the same authorization server - and gain access.

---

## 3. Hands-On Lab: Compare Token Audiences

### Two Tokens from Same Tenant

| Token | Audience | Intended For |
|-------|----------|--------------|
| Okta Org | `https://org1-pro-7fe0e.oktapreview.com` | Okta's APIs |
| Orders API | `api://orders` | Custom Orders API |

### Audience Validation Test

```powershell
# Try Orders token against Okta API (wrong audience)
Invoke-RestMethod -Uri "https://$oktaDomain/api/v1/users?limit=1" -Headers @{Authorization = "Bearer $ordersToken"}
# Result: Failed - BadRequest

# Try Okta token against Okta API (correct audience)
Invoke-RestMethod -Uri "https://$oktaDomain/api/v1/users?limit=1" -Headers @{Authorization = "Bearer $oktaToken"}
# Result: Succeeded
```

### Lab Results

| Token | Audience | API Called | Result |
|-------|----------|------------|--------|
| Orders token | `api://orders` | Okta Users API | **Rejected** |
| Okta token | `https://org1-pro-7fe0e.oktapreview.com` | Okta Users API | **Accepted** |

---

## 4. Defense in Depth

| Protection | What It Limits |
|------------|----------------|
| **Scope** | WHAT you can do |
| **Audience** | WHERE you can use it |
| **Lifetime** | HOW LONG it's valid |

A stolen token only works at ONE API for SPECIFIC actions for LIMITED time.

---

## 5. Practice Questions (with Answers)

**Q1**: Can you use an Orders token to call the Payments API?

**A1**: No. The Payments API should reject it because the audience doesn't match.

**Q2**: An API accepts any valid token without checking audience. What's the risk?

**A2**: Confused deputy - attacker could use a low-privilege token to access a different API.

**Q3**: Why did the Orders token fail against Okta's API even though it came from the same tenant?

**A3**: Audience mismatch. The token had `aud: api://orders` but Okta expected its own domain.

**Q4**: How do audience and scope work together?

**A4**: Audience limits WHERE (which API), scope limits WHAT (which actions). Together they contain blast radius.

**Q5**: "We only have one API, so we don't need audience validation." Response?

**A5**: Best practice for audits, prevents cross-tenant issues, and future-proofs when you add more APIs.

---

## 6. Key Takeaways

1. **Audience = WHERE** the token can be used
2. **APIs must validate audience** - reject mismatched tokens
3. **Confused deputy** - accepting wrong tokens enables API escalation
4. **Same client, different audiences** - one client can get tokens for multiple APIs

---

## 7. Portfolio Seed

> "I demonstrated audience validation by getting two tokens from the same Okta tenant - one for Okta's APIs and one for a custom Orders API. The Orders token was rejected by Okta's Users API even though it was valid and not expired. The audience didn't match. This prevents the confused deputy problem - without audience validation, attackers could use low-privilege tokens to access high-privilege APIs."
