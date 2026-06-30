---
name: sast-cors
description: >
  CORS misconfiguration vulnerability detection. Finds wildcard origins, null origin trust,
  credentials with wildcard, pre-flight bypass, and domain reflection attacks.
  Source: github.com/utkusen/sast-skills. Output: sast/cors-results.md
---

# SAST: CORS Misconfiguration

Detect Cross-Origin Resource Sharing (CORS) misconfigurations that allow attackers to
make cross-origin requests on behalf of authenticated users.

## Read First

Read `sast/architecture.md` before scanning. Focus on:
- API route handlers (CORS header injection points)
- Middleware/framework CORS configuration
- Environment-specific origin whitelists
- Authenticated endpoints (credentials=true)

## What to Find

### 1. Wildcard with Credentials (Critical)

```python
# VULNERABLE — browser blocks this but misconfigured servers sometimes send it
response.headers["Access-Control-Allow-Origin"] = "*"
response.headers["Access-Control-Allow-Credentials"] = "true"
```

```python
# SAFE
response.headers["Access-Control-Allow-Origin"] = "https://app.example.com"
response.headers["Access-Control-Allow-Credentials"] = "true"
```

**Framework patterns to detect:**

```python
# FastAPI / Starlette
from fastapi.middleware.cors import CORSMiddleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],        # DANGEROUS if allow_credentials=True
    allow_credentials=True,     # Combined with wildcard = critical vuln
)
```

```javascript
// Express.js
app.use(cors({ origin: '*', credentials: true }));  // VULNERABLE
```

### 2. Dynamic Origin Reflection Without Validation (High)

```python
# VULNERABLE — blindly reflects request Origin back
origin = request.headers.get("Origin")
response.headers["Access-Control-Allow-Origin"] = origin  # Any origin trusted
response.headers["Access-Control-Allow-Credentials"] = "true"
```

```python
# SAFE — validate against allowlist before reflecting
ALLOWED_ORIGINS = {"https://app.example.com", "https://admin.example.com"}
origin = request.headers.get("Origin")
if origin in ALLOWED_ORIGINS:
    response.headers["Access-Control-Allow-Origin"] = origin
    response.headers["Vary"] = "Origin"
```

### 3. Null Origin Trust (High)

```python
# VULNERABLE — 'null' origin can be sent by sandboxed iframes
if origin == "null" or origin is None:
    response.headers["Access-Control-Allow-Origin"] = "null"
    response.headers["Access-Control-Allow-Credentials"] = "true"
```

**Why dangerous:** `null` origin is sent by:
- `<iframe sandbox>` elements
- `file://` protocol requests
- Cross-origin redirects
- Serialized data: scheme (data:)

### 4. Overly Broad Domain Matching (Medium)

```python
# VULNERABLE — regex allows attacker.example.com
import re
origin = request.headers.get("Origin", "")
if re.match(r"https://.*\.example\.com", origin):
    response.headers["Access-Control-Allow-Origin"] = origin
    response.headers["Access-Control-Allow-Credentials"] = "true"
```

**Attack:** Register `attacker.example.com` → trusted.

```python
# SAFE — exact subdomain allowlist
ALLOWED_ORIGINS = {
    "https://app.example.com",
    "https://api.example.com",
    "https://admin.example.com",
}
```

### 5. Prefix/Suffix Bypass (Medium)

```python
# VULNERABLE — prefix check
if origin.startswith("https://example.com"):
    # Attacker uses: https://example.com.evil.com
    allow(origin)

# VULNERABLE — suffix check
if origin.endswith("example.com"):
    # Attacker uses: https://evil-example.com
    allow(origin)
```

### 6. Pre-flight Cache Poisoning (Low-Medium)

```http
OPTIONS /api/data HTTP/1.1
Origin: https://attacker.com
Access-Control-Request-Method: GET

HTTP/1.1 200 OK
Access-Control-Allow-Origin: https://attacker.com
Access-Control-Max-Age: 86400   ← Caches for 24h
```

Check `Access-Control-Max-Age` values — long cache times amplify impact.

### 7. Missing Vary: Origin Header (Low)

When reflecting dynamic origins, missing `Vary: Origin` causes CDN/proxy cache poisoning:

```python
# VULNERABLE — CDN caches response for one origin, serves to another
response.headers["Access-Control-Allow-Origin"] = validated_origin
# Missing: response.headers["Vary"] = "Origin"
```

## Scan Checklist

```
[ ] grep -rn "Access-Control-Allow-Origin" — find all CORS header assignments
[ ] grep -rn "allow_origins\|allowOrigins\|origins=" — find framework CORS configs
[ ] Check for wildcard (*) with allow_credentials=True
[ ] Check for origin reflection patterns (request.headers.get("Origin") → response)
[ ] Check for "null" in origin allowlists
[ ] Check regex patterns for subdomain matching (overly broad)
[ ] Check startswith/endswith checks on origin
[ ] Check Access-Control-Max-Age values
[ ] Verify Vary: Origin on dynamic origin responses
[ ] Check environment-specific configs (dev wildcard leaked to prod?)
```

## Grep Commands

```bash
# Find all CORS header assignments
grep -rn "Access-Control-Allow-Origin" --include="*.py" --include="*.js" --include="*.ts"

# Find framework CORS configs
grep -rn "CORSMiddleware\|cors(\|corsOptions\|allowedOrigins" --include="*.py" --include="*.js" --include="*.ts"

# Find origin reflection patterns
grep -rn 'headers.get.*[Oo]rigin\|request\.origin' --include="*.py" --include="*.js"

# Find potential null origin trust
grep -rn '"null"\|null.*origin\|origin.*null' --include="*.py" --include="*.js"

# Find wildcard
grep -rn 'allow_origins.*\*\|origins.*\[\s*["\x27]\*' --include="*.py" --include="*.js" --include="*.ts"
```

## Severity Classification

| Finding | CVSS | Severity |
|---------|------|----------|
| Wildcard + credentials=true | 8.1 | **CRITICAL** |
| Origin reflection without validation | 7.5 | **HIGH** |
| Null origin trusted | 7.4 | **HIGH** |
| Overly broad subdomain match | 5.3 | **MEDIUM** |
| Prefix/suffix bypass | 5.3 | **MEDIUM** |
| Missing Vary: Origin | 3.7 | **LOW** |

## Output Format

Write results to `sast/cors-results.md`:

```markdown
# CORS Misconfiguration Scan Results

## Summary
- Files scanned: N
- Findings: X critical, Y high, Z medium, W low

## Findings

### [CRITICAL] Wildcard + credentials
- File: `path/to/file.py:42`
- Code: `...`
- Impact: Any origin can make authenticated cross-origin requests
- Fix: Replace `*` with explicit origin allowlist

### [HIGH] Origin reflection without validation
- File: `path/to/middleware.py:88`
- Code: `...`
- Impact: Attacker-controlled origin trusted for authenticated endpoints
- Fix: Validate origin against strict allowlist before reflecting
```

## References

- [OWASP CORS](https://owasp.org/www-community/attacks/CORS_OriginHeaderScrutiny)
- [PortSwigger CORS](https://portswigger.net/web-security/cors)
- [utkusen/sast-skills](https://github.com/utkusen/sast-skills)
