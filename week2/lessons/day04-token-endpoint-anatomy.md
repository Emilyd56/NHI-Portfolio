# Week 2, Day 4: Token Endpoint Request Anatomy and Failure Modes

---

## 1. The Core Idea

Every token request follows a specific structure. If any part is wrong, you get an error. Understanding the anatomy helps you debug failures.

---

## 2. Token Request Anatomy

| Part | What It Is |
|------|------------|
| Endpoint | Where you send the request (e.g., /oauth2/v1/token) |
| Method | POST (always) |
| Content-Type | application/x-www-form-urlencoded |
| Auth | Client authentication (secret or JWT) |
| Grant Type | client_credentials |
| Scope | What permissions you're requesting |

---

## 3. Complete Request Example (private_key_jwt)

```http
POST /oauth2/v1/token HTTP/1.1
Host: org1-pro-7fe0e.oktapreview.com
Content-Type: application/x-www-form-urlencoded

grant_type=client_credentials
&client_id=0oady8o80iaVwAD1x0x7
&client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer
&client_assertion=eyJhbGciOiJSUzI1NiIs...
&scope=okta.users.read
```

---

## 4. Common Failure Modes

| Error | What's Wrong | What To Check |
|-------|--------------|---------------|
| invalid_client | Client auth failed | Credentials, client exists, auth method |
| invalid_scope | Scope not allowed | Scope granted to app, typo |
| invalid_grant | Grant type not allowed | App configured for client_credentials |
| invalid_request | Missing parameter | grant_type, client_id, etc. |
| unauthorized_client | Client not authorized | App can't use this flow |
| unsupported_auth_method | Wrong auth method | Using secret when key required |

---

## 5. Error Response Format

```json
{
  "error": "invalid_scope",
  "error_description": "The requested scope is invalid."
}
```

---

## 6. Debugging Checklist

1. Check the error code
2. Check error_description
3. Verify client_id
4. Verify credentials
5. Verify scope is granted
6. Verify grant_type allowed
7. Check System Log

---

## 7. Practice Questions & Answers

1. What HTTP method for token requests? → **POST**
2. What Content-Type header? → **application/x-www-form-urlencoded** (form data, not JSON)
3. invalid_scope error - cause? → **Scope not granted to the app**
4. invalid_client error - check what? → **System Log, verify client ID and credentials**
5. Where to see failed token requests? → **System Log**
