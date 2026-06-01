# Week 2, Day 3: Client Authentication Methods

---

## 1. The Core Idea

When a client requests a token, it must prove its identity to the authorization server. This is client authentication. There are multiple methods.

---

## 2. The Three Common Methods

| Method | How It Works |
|--------|--------------|
| client_secret_basic | Secret in HTTP Authorization header (Base64 encoded) |
| client_secret_post | Secret in request body as form field |
| private_key_jwt | Signed JWT assertion (no secret sent over network) |

---

## 3. client_secret_basic

Client ID and secret are combined, Base64-encoded, and sent in the Authorization header.

```
Authorization: Basic base64(client_id:client_secret)
```

Example request:
```http
POST /oauth2/v1/token HTTP/1.1
Authorization: Basic YWJjMTIzOnN1cGVyc2VjcmV0
Content-Type: application/x-www-form-urlencoded

grant_type=client_credentials&scope=okta.users.read
```

The secret travels in the header.

---

## 4. client_secret_post

Client ID and secret are sent as form fields in the request body.

```http
POST /oauth2/v1/token HTTP/1.1
Content-Type: application/x-www-form-urlencoded

grant_type=client_credentials
&client_id=abc123
&client_secret=supersecret
&scope=okta.users.read
```

The secret travels in the body.

---

## 5. private_key_jwt

Client signs a JWT with its private key and sends the signed assertion. The private key never leaves the client.

```http
POST /oauth2/v1/token HTTP/1.1
Content-Type: application/x-www-form-urlencoded

grant_type=client_credentials
&client_id=abc123
&client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer
&client_assertion=eyJhbGciOiJSUzI1NiIs...
&scope=okta.users.read
```

Only the signed proof travels - not the key itself.

---

## 6. Security Comparison

| Method | Secret Travels? | Interceptable? | Replayable? |
|--------|-----------------|----------------|-------------|
| client_secret_basic | Yes (header) | Yes | Yes |
| client_secret_post | Yes (body) | Yes | Yes |
| private_key_jwt | No | No | Limited (exp/jti) |

**Key insight**: With secret-based methods, interception = credential theft. With private_key_jwt, interception only gets a single-use assertion.

---

## 7. Why Okta Required private_key_jwt

Okta's Org Authorization Server (management APIs) blocks client secrets and requires private_key_jwt because:
- Management APIs are high-value targets
- Client secrets can be intercepted and replayed
- private_key_jwt is more secure

Custom Authorization Servers allow client secrets.

---

## 8. When Each Method Is Used

| Method | Typical Use Case |
|--------|------------------|
| client_secret_basic | Simple integrations, lower-security APIs |
| client_secret_post | Same, some systems prefer body over header |
| private_key_jwt | High-security APIs, management APIs, enterprise |

---

## 9. Practice Questions & Answers

1. In client_secret_basic, where is the secret sent? → **In the header**
2. In client_secret_post, where is the secret sent? → **In the body**
3. In private_key_jwt, does the private key travel? → **No**
4. Which method does nhi-lab-day1 use? → **Public key / private key (private_key_jwt)**
5. What if someone intercepts client_secret_basic? → **They have the credential, can replay until rotated**
