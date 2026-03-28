# RunMe — REST API specification (mobile-aligned)

This document lists REST endpoints implied by the **Flutter mobile app** (`mobile/`), including routes **already called** via `ApiClient` and endpoints **recommended** to replace in-memory repositories (loans, backings, grants, trust score, wallet, notifications).

**Conventions**

| Item | Convention |
|------|------------|
| Base URL | From app config, e.g. `https://api.example.com` (no trailing slash) |
| Auth | `Authorization: Bearer <accessToken>` unless noted |
| JSON | `Content-Type: application/json` |
| Dates | ISO 8601 strings in UTC unless noted (e.g. `2026-03-27T12:00:00.000Z`) |
| Money | Amounts as **numbers** (minor units optional; app uses **major units** as `double` for ₦) |
| IDs | String UUIDs |

**Enum values (strings in JSON)** — match Dart enum `.name` unless noted:

- `LoanStatus`: `pending` \| `funded` \| `repaid`
- `LoanPurpose`: `rent` \| `food` \| `emergency`
- `LoanAudience`: `public` \| `friendsOnly`
- `GrantCategory`: `studentStory` \| `urgentNeed` \| `education`

---

## 1. Authentication

### 1.1 Login *(implemented in `mobile`)*

`POST /auth/login`

**Request body**

| Field | Type | Required |
|-------|------|----------|
| `email` | string | ✓ |
| `password` | string | ✓ |

**Example**

```json
{
  "email": "user@school.edu",
  "password": "••••••••"
}
```

**Response `200`**

| Field | Type | Notes |
|-------|------|--------|
| `accessToken` | string | JWT or opaque token (app reads this key exactly) |

**Example**

```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Errors** — `401` invalid credentials; `422` validation.

---

### 1.2 Refresh token *(recommended)*

`POST /auth/refresh`

**Request body**

| Field | Type | Required |
|-------|------|----------|
| `refreshToken` | string | ✓ |

**Response `200`**

```json
{
  "accessToken": "…",
  "refreshToken": "…"
}
```

---

### 1.3 Logout *(optional; app clears token locally today)*

`POST /auth/logout`

**Headers:** `Authorization: Bearer <accessToken>`

**Request body** (optional)

```json
{
  "refreshToken": "…"
}
```

**Response `204`** empty body.

---

## 2. Current user & profile

### 2.1 Get current user *(implemented in `mobile`)*

`GET /me`

**Headers:** `Authorization: Bearer <accessToken>`

**Response `200`** — aligned with `Me.fromJson` in `mobile/lib/models/me.dart`

| Field | Type | Required |
|-------|------|----------|
| `id` | string | ✓ |
| `email` | string | ✓ |
| `role` | string | ✓ (e.g. `user`, `admin`) |
| `createdAt` | string | ✓ |

**Example**

```json
{
  "id": "usr_abc123",
  "email": "alex@school.edu",
  "role": "user",
  "createdAt": "2025-01-15T10:00:00.000Z"
}
```

---

### 2.2 Patch profile *(recommended for Profile screen)*

`PATCH /me` or `PATCH /users/me`

**Headers:** `Authorization: Bearer <accessToken>`

**Request body** (partial)

| Field | Type | Notes |
|-------|------|--------|
| `displayName` | string | Shown as “Alex Thompson” |
| `schoolName` | string | e.g. “Babcock University” |
| `studentIdVerified` | boolean | Drives verification badge |

**Response `200`** — same shape as `GET /me` plus new fields.

---

## 3. Admin

### 3.1 Admin summary *(implemented in `mobile`)*

`GET /admin/summary`

**Headers:** `Authorization: Bearer <accessToken>`

**Query:** none.

**Required role:** `admin` (otherwise `403`).

**Response `200`** — aligned with `AdminSummary.fromJson`

| Field | Type |
|-------|------|
| `usersCount` | number (int) |
| `generatedAt` | string (ISO8601 or display string) |

**Example**

```json
{
  "usersCount": 1240,
  "generatedAt": "2026-03-27T12:00:00.000Z"
}
```

---

### 3.2 Extended admin dashboard *(recommended)*

| Method | Path | Purpose |
|--------|------|---------|
| `GET` | `/admin/users` | Paginated users (filters, roles) |
| `GET` | `/admin/loans` | All loans / disputes |
| `GET` | `/admin/grants` | Moderation queue |
| `GET` | `/admin/audit` | Audit log |

*(Define per admin product scope; not wired in mobile yet.)*

---

## 4. Loans (P2P borrow / lend)

*Today: `LoanRepositoryImpl` in-memory. Replace with REST.*

### 4.1 List loans

`GET /loans`

**Headers:** `Authorization: Bearer <accessToken>`

**Query (optional)**

| Param | Type | Description |
|-------|------|-------------|
| `borrowerId` | string | Filter by borrower |
| `status` | string | `pending` \| `funded` \| `repaid` |
| `limit` | int | Pagination |
| `cursor` | string | Opaque cursor |

**Response `200`**

```json
{
  "items": [ { /* Loan object */ } ],
  "nextCursor": null
}
```

**Loan object** (align with `Loan` + `loan_model.dart`)

| Field | Type | Notes |
|-------|------|--------|
| `id` | string | ✓ |
| `borrowerId` | string | ✓ |
| `lenderId` | string \| null | Primary funder if single-lender model |
| `amount` | number | Principal |
| `purpose` | string | `rent` \| `food` \| `emergency` |
| `durationDays` | number (int) | |
| `interestRate` | number | Decimal APR, e.g. `0` |
| `status` | string | `pending` \| `funded` \| `repaid` |
| `createdAt` | string | ISO8601 |
| `audience` | string | `public` \| `friendsOnly` |
| `reason` | string \| null | |
| `proofFileUrl` | string \| null | Prefer URL over label only |
| `repaidAmount` | number | Principal repaid |

---

### 4.2 Get loan by ID

`GET /loans/:loanId`

**Response `200`** — single `Loan` object.

**Errors:** `404` not found.

---

### 4.3 Create loan request (borrow)

`POST /loans`

**Headers:** `Authorization: Bearer <accessToken>`

**Request body**

| Field | Type | Required |
|-------|------|----------|
| `amount` | number | ✓ |
| `purpose` | string | ✓ |
| `durationDays` | number (int) | ✓ |
| `audience` | string | ✓ |
| `reason` | string | optional |
| `proofFileUrl` | string | optional (after upload to storage) |

**Response `201`**

```json
{
  "id": "loan_…",
  "borrowerId": "usr_…",
  "lenderId": null,
  "amount": 5000,
  "purpose": "rent",
  "durationDays": 30,
  "interestRate": 0,
  "status": "pending",
  "createdAt": "2026-03-27T…",
  "audience": "public",
  "reason": "…",
  "proofFileUrl": null,
  "repaidAmount": 0
}
```

---

### 4.4 Apply repayment

`POST /loans/:loanId/repayments`

**Request body**

| Field | Type | Required |
|-------|------|----------|
| `amount` | number | ✓ (must be ≤ outstanding) |

**Response `200`** — updated `Loan` (or repayment receipt + loan).

**Errors:** `400` overpayment; `409` wrong state.

---

### 4.5 List backings / guarantees for a loan

`GET /loans/:loanId/backings`

**Response `200`**

```json
{
  "items": [
    {
      "id": "backing_…",
      "loanId": "loan_…",
      "backerId": "usr_…",
      "amountGuaranteed": 2000
    }
  ]
}
```

---

### 4.6 Create backing (fund / guarantee)

`POST /loans/:loanId/backings`

**Request body**

| Field | Type | Required |
|-------|------|----------|
| `amountGuaranteed` | number | ✓ |

**Response `201`** — `Backing` object.

**Side effects:** Update loan `status` to `funded` when fully covered (policy-dependent).

---

## 5. Marketplace / funding aggregates

*Derived from loans + backings; optional dedicated endpoints.*

### 5.1 Coverage summary for a loan *(optional)*

`GET /loans/:loanId/coverage`

**Response `200`**

```json
{
  "principal": 10000,
  "totalGuaranteed": 7500,
  "coverageRatio": 0.75
}
```

---

## 6. Trust score

*Today: `TrustScoreRepositoryImpl` local calculation.*

### 6.1 Get trust score for current user

`GET /me/trust-score`

**Response `200`**

```json
{
  "score": 87,
  "level": "High",
  "factors": {
    "verificationScore": 88,
    "repaymentScore": 92,
    "socialScore": 76,
    "activityScore": 84
  }
}
```

**Notes**

- `level` — human-readable tier (`Low` \| `Medium` \| `High` or similar).
- Factors are 0–100 each; weights can be documented server-side.

---

## 7. Grants (non-repayable gifts)

*Today: `GrantStoreNotifier` in-memory.*

### 7.1 List grants (feed)

`GET /grants`

**Query (optional)**

| Param | Type | Description |
|-------|------|-------------|
| `category` | string | `studentStory` \| `urgentNeed` \| `education` |
| `urgentOnly` | boolean | |
| `excludeBorrowerId` | string | Hide own requests (marketplace) |

**Response `200`**

```json
{
  "items": [
    {
      "id": "grant_…",
      "title": "…",
      "story": "…",
      "goalNaira": 85000,
      "raisedNaira": 41200,
      "category": "studentStory",
      "studentName": "Amaka O.",
      "createdAt": "2026-03-01T…",
      "attachmentUrls": [],
      "isUrgent": false
    }
  ]
}
```

---

### 7.2 Get grant by ID

`GET /grants/:grantId`

**Response `200`** — grant object + optional embedded counts.

---

### 7.3 Create grant request

`POST /grants`

**Request body**

| Field | Type | Required |
|-------|------|----------|
| `title` | string | ✓ |
| `story` | string | ✓ |
| `goalNaira` | number | ✓ |
| `category` | string | ✓ |
| `studentName` | string | ✓ |
| `isUrgent` | boolean | optional |
| `attachmentUrls` | string[] | optional (after upload) |

**Response `201`** — `Grant` object.

---

### 7.4 List donations for a grant

`GET /grants/:grantId/donations`

**Response `200`**

```json
{
  "items": [
    {
      "id": "don_…",
      "grantId": "grant_…",
      "donorId": "usr_…",
      "donorDisplayName": "You",
      "amountNaira": 5000,
      "createdAt": "2026-03-27T…"
    }
  ]
}
```

---

### 7.5 Donate to a grant

`POST /grants/:grantId/donations`

**Request body**

| Field | Type | Required |
|-------|------|----------|
| `amountNaira` | number | ✓ |
| `anonymous` | boolean | optional |

**Response `201`** — donation record + updated `raisedNaira`.

---

### 7.6 List comments (support messages)

`GET /grants/:grantId/comments`

**Response `200`**

```json
{
  "items": [
    {
      "id": "com_…",
      "authorName": "Tolu",
      "message": "Rooting for you!",
      "createdAt": "2026-03-27T…"
    }
  ]
}
```

---

### 7.7 Post comment

`POST /grants/:grantId/comments`

**Request body**

| Field | Type | Required |
|-------|------|----------|
| `authorName` | string | ✓ |
| `message` | string | ✓ |

**Response `201`** — comment object.

---

## 8. Wallet

*Today: hardcoded balance on Home; no API.*

### 8.1 Get wallet

`GET /me/wallet`

**Response `200`**

```json
{
  "balanceNaira": 12480.52,
  "currency": "NGN"
}
```

---

### 8.2 Fund wallet *(optional)*

`POST /me/wallet/deposits`

**Request body**

```json
{
  "amountNaira": 5000,
  "provider": "paystack",
  "callbackUrl": "https://…"
}
```

**Response `200`** — payment intent / redirect URL.

---

### 8.3 Withdraw *(optional)*

`POST /me/wallet/withdrawals`

**Request body**

```json
{
  "amountNaira": 2000,
  "bankAccountId": "bnk_…"
}
```

---

## 9. Bank accounts (settings)

*Profile “Bank account” is a stub.*

### 9.1 List bank accounts

`GET /me/bank-accounts`

### 9.2 Link bank account

`POST /me/bank-accounts`

**Request body example**

```json
{
  "accountNumber": "0123456789",
  "bankCode": "058",
  "accountName": "Alex Thompson"
}
```

---

## 10. Notifications

*App navigates to `/notifications` with static content.*

### 10.1 List notifications

`GET /me/notifications`

**Query:** `limit`, `cursor`, `unreadOnly`

**Response `200`**

```json
{
  "items": [
    {
      "id": "ntf_…",
      "title": "Wallet top-up confirmed",
      "body": "…",
      "read": false,
      "createdAt": "2026-03-27T…",
      "type": "wallet" 
    }
  ]
}
```

---

### 10.2 Mark read

`PATCH /me/notifications/:id/read`

---

## 11. File uploads

*Proof uploads (loans) and grant media use `file_picker` locally; backend should return URLs.*

### 11.1 Presigned upload *(recommended)*

`POST /uploads/presign`

**Request body**

```json
{
  "purpose": "loan_proof" | "grant_media",
  "contentType": "image/jpeg",
  "fileName": "receipt.jpg"
}
```

**Response `200`**

```json
{
  "uploadUrl": "https://…",
  "fileUrl": "https://cdn…/final-path",
  "headers": {}
}
```

Client `PUT`s file to `uploadUrl`, then sends `fileUrl` in loan/grant APIs.

---

## 12. Errors (recommended shape)

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "durationDays must be between 7 and 90",
    "details": {}
  }
}
```

Common HTTP codes: `400`, `401`, `403`, `404`, `409`, `422`, `429`, `500`.

---

## 13. Summary table (quick reference)

| Method | Path | Auth | Mobile status |
|--------|------|------|-----------------|
| `POST` | `/auth/login` | No | **Wired** |
| `GET` | `/me` | Yes | **Wired** |
| `GET` | `/admin/summary` | Yes (admin) | **Wired** |
| `GET` | `/loans` | Yes | *Suggested* |
| `POST` | `/loans` | Yes | *Suggested* |
| `GET` | `/loans/:id` | Yes | *Suggested* |
| `POST` | `/loans/:id/repayments` | Yes | *Suggested* |
| `GET` | `/loans/:id/backings` | Yes | *Suggested* |
| `POST` | `/loans/:id/backings` | Yes | *Suggested* |
| `GET` | `/me/trust-score` | Yes | *Suggested* |
| `GET` | `/grants` | Yes | *Suggested* |
| `POST` | `/grants` | Yes | *Suggested* |
| `POST` | `/grants/:id/donations` | Yes | *Suggested* |
| `GET` | `/grants/:id/comments` | Yes | *Suggested* |
| `POST` | `/grants/:id/comments` | Yes | *Suggested* |
| `GET` | `/me/wallet` | Yes | *Suggested* |
| `GET` | `/me/notifications` | Yes | *Suggested* |
| `POST` | `/uploads/presign` | Yes | *Suggested* |

---

## 14. Versioning

Prefix all routes with `/v1` if desired (e.g. `GET /v1/me`); update `AppConfig.serverBaseUrl` + `ApiClient` paths accordingly.

---

## 15. Database & hosting (Supabase + Koyeb)

The Node server expects **PostgreSQL** (tested with **Supabase**) and **Redis**. See **[SUPABASE.md](./SUPABASE.md)** for connection strings, applying `server/drizzle/0000_init.sql`, and Koyeb notes. All **`server/` env vars** are documented in **[SERVER_ENV.md](./SERVER_ENV.md)**.

---

## 16. Swagger UI (interactive testing)

When the API is running:

| URL | Purpose |
|-----|---------|
| **`/docs`** | Swagger UI — try requests, set **Authorize** with `accessToken` from login |
| **`/openapi.json`** | Raw OpenAPI 3.0 document (import into Postman, Insomnia, etc.) |

The spec file in the repo is `server/src/openapi/openapi.json`.

---

*Generated from the RunMe mobile Flutter codebase structure and domain models. Extend as new screens ship.*
