# Week 3, Day 4: Claims - What Belongs in a Token and What Does Not

**Date**: June 6, 2026  
**Quiz Score**: 5/5

---

## 1. Core Idea

A **claim** is a piece of information about the subject embedded in a token. Claims are key-value pairs in the JWT payload.

---

## 2. Concept Breakdown

### Standard Claims (JWT Specification)

| Claim | Name | Purpose |
|-------|------|---------|
| `iss` | Issuer | Who issued this token |
| `sub` | Subject | Who/what this token is about |
| `aud` | Audience | Who this token is for |
| `exp` | Expiration | When the token expires |
| `iat` | Issued At | When the token was issued |

### Custom Claims

Defined by you for your API:
- `app_type` - type of application
- `can_write` - boolean permission flag
- `tenant_id` - customer tenant

---

## 3. What Belongs vs What Doesn't

### SHOULD Be in Token

| Data | Why |
|------|-----|
| Identity (`sub`, `cid`) | API needs to know who's calling |
| Permissions (`scp`) | API needs to know what's allowed |
| Expiration (`exp`) | API needs to know if token is valid |

### Should NEVER Be in Token

| Data | Why Not |
|------|---------|
| Passwords | Tokens are signed, not encrypted |
| API keys/secrets | Visible to anyone with token |
| Credit card numbers | PCI violation |
| SSN | PII violation |

**Golden Rule**: Tokens are signed, not encrypted. Only include what you'd be comfortable with being visible.

---

## 4. Hands-On Lab: Add Custom Claims

### Static Claim (Always Included)

In Okta Admin → Security → API → Orders API → Claims:
- Name: `app_type`
- Value: `"service_app"`
- Include in: Any scope

### Conditional Claim (Scope-Based)

- Name: `can_write`
- Value: `true`
- Include in: Only `orders:write` scope

### Results

| Token | Scopes | Claims |
|-------|--------|--------|
| Read-only | `orders:read` | `app_type: "service_app"` |
| Write | `orders:write` | `app_type`, `can_write: true` |

---

## 5. Why Claims Simplify Authorization

**Without claims:**
```javascript
function canWrite(token) {
  return scopes.includes("orders:write") || 
         scopes.includes("orders:admin") ||
         scopes.includes("admin:all");
}
```

**With claims:**
```javascript
function canWrite(token) {
  return token.can_write === true;
}
```

| Approach | Logic Location | Change Impact |
|----------|----------------|---------------|
| Parse scopes | Every API | Update all APIs |
| Use claims | Auth server | Update one place |

Claims are **pre-computed answers** to authorization questions.

---

## 6. Practice Questions (with Answers)

**Q1**: What is a claim in a JWT?

**A1**: A key-value pair in the token payload containing information about the subject.

**Q2**: Why is `can_write: true` useful?

**A2**: Centralizes authorization logic in the auth server. API just checks a flag instead of parsing scope strings.

**Q3**: Why shouldn't passwords be in tokens?

**A3**: Tokens are signed, not encrypted. Anyone with the token can decode and read it.

**Q4**: Difference between standard and custom claims?

**A4**: Standard claims are defined by JWT spec (iss, sub, aud). Custom claims are defined by you for your API.

**Q5**: What does `exp: 1780802608` mean?

**A5**: Expiration time as Unix timestamp. Token is invalid after this time, limiting blast radius of compromise.

---

## 7. Key Takeaways

1. **Claims are key-value pairs** in the token payload
2. **Standard claims** defined by JWT spec, custom claims defined by you
3. **Never include sensitive data** - tokens are readable by anyone
4. **Claims centralize authorization** - auth server computes, APIs just check
5. **Conditional claims** appear only for certain scopes

---

## 8. Portfolio Seed

> "I added custom claims to an Okta authorization server. A static claim `app_type` appears in all tokens, while `can_write: true` only appears with `orders:write` scope. This moves authorization logic to the auth server - APIs check claim values instead of parsing scope lists. And tokens are signed, not encrypted - never include sensitive data."
