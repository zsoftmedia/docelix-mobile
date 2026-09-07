# Docelix mobile backend handoff

Prepared from the backend source on **2026-09-07**.

- Source branch: `staging`
- Source commit: `250981e`
- API code compared with `main` (`09a4a2b`): identical; staging has one additional subscription migration.
- Runtime: Node.js 18, Express 5, TypeScript, Supabase/Postgres, Supabase Storage, Supabase Auth, Stripe, OpenAI/OCR, Gmail, Outlook, IMAP/SMTP, Google Maps.

This is the implementation handoff for an iOS, Android, Flutter, or React Native client. The TypeScript source remains the final source of truth because the project does not currently publish an OpenAPI specification.

## 1. Environments and configuration

### Confirmed production

| Setting | Value |
|---|---|
| REST API base URL | `https://docelix.onrender.com` |
| API prefix | `/api` |
| Supabase project URL | `https://uqhufdevsnstdpcbgace.supabase.co` |
| Default currency | `EUR` |
| Backend region | Render Frankfurt |

`GET https://docelix.onrender.com/api/stripe/plans` returned HTTP 200 on 2026-09-07.

The mobile team must receive the production **Supabase anon/publishable key** through the team's configuration channel. It is safe to embed the anon/publishable key in a mobile client when RLS is correct, but it must not be confused with a server secret.

### Local development

| Service | URL |
|---|---|
| Express API | `http://localhost:3000` |
| Supabase API/Auth | `http://127.0.0.1:54321` |
| Postgres | `127.0.0.1:54322` |
| Supabase Studio | `http://127.0.0.1:54323` |

Start with `npm run dev:local`, or start Supabase and the Express server separately. An Android emulator normally reaches the host as `10.0.2.2`, not `localhost`. A physical device needs a LAN-reachable HTTPS development URL or tunnel.

### Staging

`render.yaml` declares a staging service, but the implied URL `https://docelix-backend-staging.onrender.com` returned 404 on 2026-09-07. Do not hard-code it. The backend owner must provide or create a working staging API and the matching staging Supabase URL/anon key before mobile QA.

### Never ship these values in the app

- `SUPABASE_SERVICE_ROLE_KEY`
- `SUPABASE_JWT_SECRET`
- `OPENAI_API_KEY`
- Stripe secret or webhook secret
- Google/Outlook client secrets or OAuth state secrets
- SMTP/IMAP passwords or `EMAIL_CONFIG_ENCRYPTION_KEY`
- Database connection credentials

The Express server uses the Supabase service-role key. The mobile app must use only the anon/publishable key and the user's access token.

## 2. Authentication and session lifecycle

The Express API has no ordinary login or refresh endpoint. Mobile authentication must use a Supabase client SDK against the same Supabase project as the API.

Recommended flow:

1. Sign up or sign in through Supabase Auth (email/password is enabled in the local config).
2. Store the refreshable session in Keychain/Keystore-backed secure storage.
3. Let the Supabase SDK refresh the session. Local configuration uses 1-hour access tokens, refresh-token rotation, and a 10-second reuse interval.
4. Send the current access token on every protected Express request:

   ```http
   Authorization: Bearer <supabase-access-token>
   ```

5. After a first sign-in, call `POST /api/users` and then `GET /api/me`. The database trigger also creates the public user row and, for non-invited users, a default `My Workspace` company. `GET /api/me` can repair a missing public profile row.
6. On logout, clear both the Supabase session and all cached company data.

The token `sub` becomes `req.user.user_id` and is a UUID string. A token from a different Supabase project returns 401 with `Token issuer mismatch`.

Use a password of at least 8 characters. Supabase local configuration permits 6, but employee and consultant invitation acceptance requires 8.

### Invitation authentication

Employee and consultant invitation acceptance endpoints are public and accept `{ "password": "..." }`. They create or update the Supabase Auth user but do not return a mobile session. After accepting, sign in through the Supabase SDK with the invitation email and password.

### Hanko

The repository still contains a Hanko dependency and `HANKO_API_URL`, plus a few legacy comments, but current `requireAuth` verifies Supabase JWTs. Do not implement Hanko in the new app unless the backend team explicitly reverses this decision.

### Secure client behavior

- Refresh once and retry once after a 401. Do not loop indefinitely.
- Never log bearer or refresh tokens.
- Clear tenant-specific caches when the selected company changes.
- Treat 403/402 as an entitlement problem, not an authentication failure.
- Prevent screenshots/logging of email-provider credentials and sensitive financial documents where the platform permits it.

## 3. Standard request contract

### Headers

For protected calls:

```http
Authorization: Bearer <access-token>
Accept: application/json
Content-Type: application/json
x-company-id: <numeric-company-id>
```

The selected company is a numeric ID. The API is inconsistent about company context:

- Core resources usually require `company_id` in the JSON body and `?company_id=` on GETs.
- Banking, cash, inventory, vehicles, tax, and reports usually require `x-company-id`.
- Several endpoints accept any of body, query, or header.

The safest mobile API layer should always set `x-company-id` after company selection **and** put `company_id` in the endpoint-specific location documented below. Never assume the header replaces a required body/query value.

Native networking normally sends no browser `Origin`, so browser CORS is not a native-app blocker. A WebView may need an origin added to `CORS_ALLOWED_ORIGINS`.

### Data representation

- Most business IDs are JSON numbers; auth/user IDs and activity IDs are UUID strings.
- Dates are normally `YYYY-MM-DD`.
- Timestamps are ISO-8601 strings.
- Postgres `numeric` values can arrive as JSON strings, especially incoming-invoice totals and VAT rates. Mobile decoders should accept both number and numeric string and use a decimal/money type, not binary floating point, for calculations.
- Currency codes are uppercase, three-character codes; `EUR` is the default.
- JSON body limit is 25 MB. Files use `multipart/form-data`.

### Responses and errors

There is not yet a single response envelope. Successful calls may return a raw object/array, `{ data }`, `{ items, total, page, limit }`, or `{ ok: true, data }`.

Errors may be `{ error: string }` or `{ message: string }`. Normalize both in the client:

```ts
const message = json.error ?? json.message ?? `Request failed (${status})`;
```

Important status codes:

| Code | Meaning |
|---|---|
| 200/201 | Success/created |
| 204 | Success with no body |
| 400 | Invalid or missing input/company context |
| 401 | Missing, expired, invalid, or wrong-project token |
| 402 | Subscription feature/usage limit reached |
| 403 | Authenticated but insufficient company permission |
| 404 | Resource not found |
| 409 | Duplicate/conflicting state |
| 410 | Invitation expired |
| 413/415 | File too large/unsupported type (some Multer errors may currently surface as 500) |
| 422 | File accepted but could not be parsed |
| 500/503 | Server/integration/configuration failure |

Only Stripe checkout currently has an explicit idempotency input (`requestId`). Disable duplicate submission in the UI for other POST operations.

## 4. Bootstrap and company selection

Call these after authentication:

1. `POST /api/users` with optional `{ email, username, role_id }`. Email normally comes from the token.
2. `GET /api/me`.
3. Select one of `companies` returned by `/api/me`.
4. Read the selected company's `my_plan_features` and role fields to build navigation.

`GET /api/me` returns the user/role plus:

```ts
type Me = {
  id: number;
  user_id: string;
  email: string;
  username: string | null;
  role_id: number;
  role: { name: string; description: string | null };
  avatar: { mime_type: string; size_bytes: number; updated_at: string } | null;
  companies: CompanyWithAccess[];
  avatar_data: unknown; // legacy Buffer JSON; prefer GET /api/me/avatar
  avatar_mime_type: string | null;
};
```

Owned companies include `my_role: "owner"`. Employee companies also include `my_role`, `my_access_level`, and `my_custom_permissions`. Every returned company includes `my_plan_features`.

Use `GET /api/me/avatar` and `GET /api/companies/avatar/:id` as authenticated binary image requests. Both can return 204 when no image exists.

## 5. Roles, permissions, and plans

Company access is allowed for the owner, a global admin, an active `company_account_access` assignment, or an active employee record.

Permission names used by the API:

```text
invoice.read/create/update/delete
customer.read/create/update/delete
item.read/create
accounting.read/manage
tax.read/manage
report.read
company.manage
user.manage
integration.manage
offer.read/create/update/delete
asset.read/manage
```

Access levels are `restricted`, `full`, and `super`. Owner/admin and `super` get management permissions; `full` gets accounting/tax/report/asset access and destructive resource permissions. `custom_permissions` overrides defaults.

Plan feature flags:

```ts
type PlanFeatures = {
  hasFinance: boolean;
  hasTaxes: boolean;
  hasReports: boolean;
  hasAssets: boolean;
  hasAI: boolean;
  hasMail: boolean;
  hasTeamAccess: boolean;
  hasActivityLog: boolean;
  maxIncomingInvoices: number | null;
};
```

Current backend enforcement makes `founder`, `business`, `professional`, and `accountant` fully enabled. `starter` has every boolean above set to false and allows 20 incoming invoices per month. The Founder entitlement is downgraded after its stored period end. Use the flags returned by the API; do not duplicate the matrix in the app.

## 6. Core payloads

### Company

Company create/update accepts JSON or multipart with file field `logo` (2 MB middleware limit). The mobile client should prefer multipart for images.

Common fields:

```ts
type CompanyInput = {
  name: string;
  tax_id?: string | null;
  iban?: string | null;
  bic?: string | null;
  phone_number?: string | null;
  tel_number?: string | null;
  contact_email?: string | null;
  website?: string | null;
  address_line1?: string | null;
  address_line2?: string | null;
  postal_code?: string | null;
  city?: string | null;
  country?: string | null;
  footer?: string | null;
  legal_name?: string | null;
  registration_number?: string | null;
  registration_court?: string | null;
  registration_date?: string | null;
  gisa_number?: string | null;
  legal_form?: string | null;
  company_status?: string | null;
  business_activity?: string | null;
  vat_registered?: boolean;
  vat_number?: string | null;
  vat_exemption_text?: string | null;
  fiscal_year?: string | null;
  accounting_method?: string | null;
  vat_accounting_method?: "sollbesteuerung" | "istbesteuerung";
  industry_id?: number | null;
  custom_industry_name?: string | null;
};
```

If `vat_registered` is true, `vat_number` is required. When false, the backend clears `vat_number`.

### Client/customer

```ts
type ClientInput = {
  company_id: number;
  name: string;
  email?: string | null;
  phone?: string | null;
  address_line1?: string | null;
  address_line2?: string | null;
  postal_code?: string | null;
  city?: string | null;
  country?: string | null;
  vat_id?: string | null;
};
```

### Catalog item

```ts
type CatalogItemInput = {
  company_id: number;
  article_name: string;
  article_number?: string | null; // generated when omitted
  description?: string | null;
  unit_code: string;
  default_qty?: number;           // > 0, default 1
  unit_price_net: number;         // >= 0
  purchase_price_net?: number | null;
  unit_price_gross?: number | null;
  discount?: number | null;
  group_code?: string | null;
  price_msrp?: number | null;
  stock_qty?: number;             // >= 0
  min_stock?: number;             // >= 0
  track_stock?: boolean;
  item_type?: "physical" | "software" | "service" | "digital";
  vat_rate?: number;              // 0..100, default 20
};
```

Only physical items can track stock. Initial tracked stock creates an `INITIAL` movement.

### Outgoing invoice

```ts
type InvoiceCreate = {
  company_id: number;
  client_id: number;
  invoice_number: string;
  issue_date?: string;
  due_date?: string | null;
  notes?: string | null;
  notes_pre?: string | null;
  notes_post?: string | null;
  layout_order?: string[] | null;
  items?: Array<{
    catalog_item_id?: number | null;
    item_desc: string;
    quantity: number;
    unit_price: number;
    vat_rate: number;
    gross_amount: number;
  }>;
  schedule?: {
    enabled: boolean;
    frequency: "weekly" | "monthly" | "yearly";
    interval: number;
    startDate: string;
    endType: "never" | "date" | "count";
    endDate?: string;
    endCount?: number;
    autoSendEmail: boolean;
  };
};
```

Invoice update accepts `client_id`, `invoice_number`, `issue_date`, `due_date`, `notes`, `notes_pre`, `notes_post`, `layout_order`, `status`, and optionally a complete replacement `items` array. Allowed status values are `draft`, `sent`, `unpaid`, `paid`, `overdue`, `cancelled`, and `due`. The model also recognizes `partially paid` when payment totals update automatically.

Payment create:

```ts
{
  payment_date: string;
  amount: number; // > 0
  payment_method?: string | null;
  reference?: string | null;
  notes?: string | null;
}
```

### Incoming invoice/receipt

Upload is multipart field `file`, plus `company_id`, optional `status`, `expense_category`, `expense_account_code`, and `expense_account_id`. Accepted MIME types are PDF, JPEG, PNG, WebP, HEIC, and HEIF; maximum 50 MB. The backend performs OCR/AI extraction and returns a signed file URL valid for about 10 minutes.

Incoming-invoice row:

```ts
type IncomingInvoice = {
  id: number;
  company_id: number;
  user_id: string;
  file_name: string;
  file_url: string;
  file_type: "image" | "pdf";
  mime_type: string;
  size_bytes: number | null;
  supplier_name: string | null;
  supplier_email: string | null;
  supplier_phone: string | null;
  supplier_address_line1: string | null;
  supplier_address_line2: string | null;
  supplier_city: string | null;
  supplier_postal: string | null;
  supplier_country: string | null;
  invoice_number: string | null;
  invoice_date: string | null;
  currency: string | null;
  total_amount: string | null;
  vat_rate_percent: string | null;
  expense_category: string | null;
  expense_account_id: number | null;
  expense_account_code: string | null;
  payment_method: string | null;
  ocr_text: string | null;
  status: "paid" | "unpaid" | null;
  uploaded_at?: string;
  updated_at?: string;
};
```

Editable fields are the supplier fields above, invoice number/date, currency, total, VAT rate, expense category/account, and status. Manual creation minimally requires `company_id` and `total_amount`; it also accepts supplier name, invoice number/date, status, and expense account ID.

### Offer

```ts
type OfferCreate = {
  company_id: number;
  client_id?: number | null;
  offer_number: string;
  issue_date?: string;
  vortext?: string;
  schlusstext?: string;
  vortext_pages?: string[];
  schlusstext_pages?: string[];
  layout_order?: string[];
  items: Array<{
    item_desc: string;
    quantity: number;
    unit_price: number;
    vat_rate: number;
    gross_amount: number;
  }>;
};
```

Offer statuses are `draft`, `sent`, `accepted`, `rejected`, `converted`, and `expired`. Currency is currently stored as EUR. Send uses multipart with PDF field `file`, plus `company_id`, `to`, `subject`, and `text`.

### Ledger journal entry

```ts
{
  company_id: number;
  entry_date?: string;
  source_type?: string | null;
  source_id?: number | null;
  description?: string | null;
  status?: "draft" | "posted" | "void";
  lines: Array<{
    account_id: number;
    debit: number;
    credit: number;
    description?: string | null;
  }>;
}
```

At least two lines are required. Each line has either debit or credit greater than zero, never both, and total debit must equal total credit.

## 7. Complete endpoint inventory

`Auth` means bearer token required. `Company` states where the controller expects company context. Plan gates are in parentheses.

### Public and bootstrap

| Method | Path | Auth | Company/input | Response/use |
|---|---|---:|---|---|
| GET | `/api/roles` | No | — | Role list |
| POST | `/api/users` | Yes | optional profile fields | Upsert public user |
| GET | `/api/me` | Yes | — | Profile, companies, roles, plan flags |
| PATCH | `/api/me` | Yes | multipart `avatar`, `username`, `email` | Updated profile |
| GET | `/api/me/avatar` | Yes | — | Image bytes or 204 |
| POST | `/api/public/demo-request` | No | name/contact/company/message | Create demo lead |
| GET | `/api/public/gdpr` | No | — | `{ data: activePolicy }` |

There is no health/version endpoint.

### Companies and documents

| Method | Path | Auth | Company/input | Notes |
|---|---|---:|---|---|
| GET | `/api/companies` | Yes | — | Owned and employee companies |
| POST | `/api/companies` | Yes | body; optional multipart `logo` | Creates company and Founder subscription |
| PUT | `/api/companies/:id` | Yes | owner only; optional `logo` | Full/partial body accepted |
| DELETE | `/api/companies/:id` | Yes | owner only | 409 when dependent rows exist |
| GET | `/api/companies/avatar/:id` | Yes | ID in path | Image bytes or 204 |
| GET | `/api/companies/:id/documents` | Yes | path ID; `company.manage` | Signed URLs |
| POST | `/api/companies/:id/documents` | Yes | multipart `file`; `document_type` | 2 MB route limit |
| POST | `/api/companies/:id/documents/:docId/extract` | Yes | path IDs | OCR/AI extraction |
| DELETE | `/api/companies/:id/documents/:docId` | Yes | path IDs | Deletes DB/storage object |

### Dashboard, clients, catalog, currencies

| Method | Path | Company/input | Notes |
|---|---|---|---|
| GET | `/api/dashboard/metrics` | query `company_id` | Currently reminders sent this month |
| GET | `/api/dashboard/accounting` | query `company_id`, `from`, `to`; optional `compareFrom`, `compareTo`, `groupBy` | Finance dashboard |
| GET | `/api/clients` | query `company_id`; optional `q`, `limit`, `offset` | Raw array |
| POST | `/api/clients` | body `company_id` + ClientInput | 201 row |
| PUT | `/api/clients/:id` | patch body | Updated row |
| DELETE | `/api/clients/:id` | resource ID | `{ success, id }` |
| GET | `/api/client-list` | query `company_id` | Legacy second customer list |
| POST | `/api/client-list` | body `company_id` + client fields | Legacy |
| PUT | `/api/client-list/:id` | patch body | Legacy |
| DELETE | `/api/client-list/:id` | resource ID | Archives; 204 |
| GET | `/api/units` | — | `[{ code, label }]` |
| GET | `/api/currencies` | — | Currency list |
| GET | `/api/catalog` | query `company_id`; optional `q` | Raw array |
| POST | `/api/catalog` | body `company_id` + CatalogItemInput | 201 row |
| PATCH | `/api/catalog/:id` | query/body `company_id` | `{ success, item }` |
| DELETE | `/api/catalog/:id` | query `company_id` | Hard delete |
| DELETE | `/api/catalog` | query `company_id&all=true` | Hard delete all; confirmation required |
| POST | `/api/catalog/import-items` | multipart `file`, `company_id` | XLS/XLSX, 10 MB |

All routes in this section except public routes require Auth. Dashboard endpoints also require report/accounting permissions.

### Outgoing invoices

| Method | Path | Company/input | Notes |
|---|---|---|---|
| GET | `/api/invoices` | query `company_id` | Rows include `recurring_invoices` |
| POST | `/api/invoices` | body `company_id` + InvoiceCreate | Returns header; fetch items separately |
| PATCH | `/api/invoices/:id` | patch body; company resolved from ID | May replace all items |
| DELETE | `/api/invoices/:id` | resolved from ID | Removes items and invoice |
| GET | `/api/invoices/:id/items` | resolved from ID | Line items |
| GET | `/api/invoices/:id/payments` | resolved from ID | Payment array |
| POST | `/api/invoices/:id/payments` | payment body | Recalculates paid/remaining/status |
| POST | `/api/invoices/:id/send` | multipart `file`, `company_id`, `to`, `subject`, `text` | Sends PDF and sets `sent` |
| POST | `/api/invoices/:id/send-reminder` | multipart files, `company_id`, `to`, `subject`, `html` | Records attempt/history |
| GET | `/api/invoices/:id/reminders` | query `company_id` | Simplified reminder array |
| GET | `/api/invoices/recurring` | query `company_id` | Schedule list |
| PATCH | `/api/invoices/recurring/:id/status` | body `company_id`, `status` | Active/paused/cancelled/completed |

All require Auth and invoice permissions.

### Incoming invoices

| Method | Path | Company/input | Notes |
|---|---|---|---|
| GET | `/api/incoming-invoices` | query `company_id`, `page`, `limit`, optional `q`, dates/totals | `{ items, total }`; limit max 100 |
| GET | `/api/incoming-invoices/usage` | query/header company | `{ used, limit, remaining, period_start, period_end }` |
| POST | `/api/incoming-invoices/upload` | multipart `file`, body `company_id` | OCR/AI; 50 MB |
| POST | `/api/incoming-invoices/manual` | JSON body `company_id`, `total_amount`, optional fields | No file |
| PATCH | `/api/incoming-invoices/:id` | edit body; company resolved from resource | Rebuilds ledger entries |
| PATCH | `/api/incoming-invoices/:id/status` | `{ status: "paid" | "unpaid" }` | Posts/reverses payment ledger entry |
| DELETE | `/api/incoming-invoices/:id` | company resolved from resource | Deletes ledger/storage/data |

### Offers and templates

| Method | Path | Auth | Company/input | Notes |
|---|---|---:|---|---|
| GET | `/api/offers` | Yes | query `company_id`; optional `client_id`, `status` | Offer list |
| POST | `/api/offers` | Yes | OfferCreate body | 201 `{ id, offer_number }` |
| GET | `/api/offers/:id` | Yes | resource ID | Offer only |
| GET | `/api/offers/:id/items` | Yes | resource ID | Items |
| PUT | `/api/offers/:id` | Yes | complete offer payload | Replaces header/items |
| POST | `/api/offers/:id/send` | Yes | multipart PDF and email fields | Returns public link/token expiry |
| DELETE | `/api/offers/:id` | Yes | resource ID | `{ success: true }` |
| GET | `/api/public/offer/:token` | No | public token | Public offer |
| GET | `/api/public/offer/:token/pdf` | No | public token | PDF/binary response |
| POST | `/api/public/offer/:token/accept` | No | required `signature`; optional PDF `pdfBase64` | Accepts offer |
| POST | `/api/public/offer/:token/reject` | No | optional `reason` | Rejects offer |
| GET | `/api/templates` | Yes | query/header/body company | Document templates |
| POST | `/api/templates` | Yes | `company_id`, `name`, `vortext`, `schlusstext`, `layout_order` | Create |
| DELETE | `/api/templates/:id` | Yes | company context | 204 |

### AI editor (`hasAI`)

| Method | Path | Company/input | Notes |
|---|---|---|---|
| POST | `/api/ai/editor/apply` | `company_id`, `html`, `instruction`, optional `lang` | `{ ok, html, ... }` |
| POST | `/api/ai/editor/apply-with-files` | multipart `files` (max 5), same text fields | PDF/JPEG/PNG/WebP, 25 MB per middleware request |
| POST | `/api/ai/editor/import-pdf` | multipart `file`, company | PDF only, 25 MB |
| GET | `/api/ai/editor/templates` | query/header company | Editor-template list |
| POST | `/api/ai/editor/templates` | body company + template fields | Create editor template |
| DELETE | `/api/ai/editor/templates/:id` | company context | Delete |
| POST | `/api/ai/index/bootstrap` | body/query `company_id` | Index all company data |

These calls can be slow. Use progress/loading UX and a longer request timeout; do not automatically retry AI mutations.

### Ledger and statement import (`hasFinance`)

| Method | Path | Company/input | Notes |
|---|---|---|---|
| POST | `/api/ledger/bootstrap` | body `company_id`, optional currency | Seeds chart of accounts |
| GET | `/api/ledger/accounts` | query `company_id` | `{ items }` |
| POST | `/api/ledger/journal-entries` | journal payload | Owner-only inside controller |
| GET | `/api/ledger/journal-entries` | query company, `page`, `limit` | Paginated, max 100 |
| DELETE | `/api/ledger/journal-entries` | query/body `company_id`, `source_id`, `source_type` | Deletes by source, not arbitrary ID |
| GET | `/api/ledger/statements` | query company, `page`, `limit` | Statement imports |
| DELETE | `/api/ledger/statements/:statement_id` | query/body company | Deletes statement and transactions |
| POST | `/api/ledger/statements/import` | multipart `file`, body `company_id` | PDF/XML/OFX/XLS/XLSX/CSV, 50 MB |
| GET | `/api/ledger/bank-transactions` | query company, optional `statement_id`, `page`, `limit` | Imported statement transactions |
| POST | `/api/ledger/bank-transactions/:transaction_id/match` | body company, `counter_account_id`, optional `note` | Posts journal entry |
| POST | `/api/ledger/bank-transactions/auto-match` | body `company_id` | Automatic reconciliation |

### Banking, cash, inventory (`hasFinance`/`hasAssets`)

All require `x-company-id`.

| Method | Path | Input/use |
|---|---|---|
| GET | `/api/banking/accounts` | `{ data: BankAccount[] }` |
| POST | `/api/banking/accounts` | `bank_name`, `iban`, optional currency/opening balance/account number/status |
| GET | `/api/banking/accounts/:id/transactions` | `{ data: BankTransaction[] }` |
| POST | `/api/banking/accounts/:id/transactions` | date, amount, description, counterparty, reference, status |
| GET | `/api/cash/accounts` | `{ data: CashAccount[] }` |
| POST | `/api/cash/accounts` | name, currency, opening balance/date, notes, active flag |
| GET | `/api/cash/accounts/:id/transactions` | `{ data: CashTransaction[] }` |
| POST | `/api/cash/accounts/:id/transactions` | type, date, amount, references, description, status |
| GET | `/api/inventory/items` | Catalog items plus `calculated_stock` |
| GET | `/api/inventory/items/:id/movements` | Movement history |
| POST | `/api/inventory/items/:id/movements` | movement type, quantity, optional warehouse/reference/date/notes |

Cash types: `OPENING_BALANCE`, `INCOME`, `EXPENSE`, `TRANSFER_TO_BANK`, `TRANSFER_FROM_BANK`, `ADJUSTMENT`, `REFUND`, `WITHDRAWAL`, `DEPOSIT`.

Inventory types: `INITIAL`, `PURCHASE`, `SALE`, `RETURN`, `TRANSFER`, `ADJUSTMENT`, `LOSS`, `DAMAGED`.

### Accounting summaries and reports

All require Auth and `x-company-id` (some summaries also accept query `company_id`).

| Method | Path | Query |
|---|---|---|
| GET | `/api/accounting/receivables/dashboard` | optional `from`, `to` |
| GET | `/api/accounting/receivables/invoices` | — |
| GET | `/api/accounting/receivables/customers` | — |
| GET | `/api/accounting/payables/dashboard` | optional `from`, `to` |
| GET | `/api/accounting/payables/bills` | — |
| GET | `/api/accounting/payables/suppliers` | — |
| GET | `/api/accounting/reports/validation` | — |
| GET | `/api/accounting/reports/trial-balance` | required `fromDate`, `toDate`; optional `includeZeroBalances` |
| GET | `/api/accounting/reports/general-ledger` | required dates; optional `accountId`, `search`, `sourceType`, `page`, `pageSize` |
| GET | `/api/accounting/reports/profit-loss` | required `fromDate`, `toDate` |
| GET | `/api/accounting/reports/balance-sheet` | required `asOfDate` |

Summary endpoints require `hasFinance`; report endpoints require `hasReports`.

### Tax (`hasTaxes`)

All require Auth, tax permission, and `x-company-id`.

| Method | Path | Input |
|---|---|---|
| GET | `/api/tax/returns/:taxYear` | Year path |
| POST | `/api/tax/returns/:taxYear` | Create annual return |
| POST | `/api/tax/returns/:taxYear/recalculate` | Recalculate |
| GET | `/api/tax/returns/:taxYear/reconciliation` | Reconciliation summary |
| GET | `/api/tax/returns/:taxYear/income` | Income detail |
| GET | `/api/tax/returns/:taxYear/expenses` | Expense detail |
| GET | `/api/tax/returns/:taxYear/adjustments` | Adjustment list |
| POST | `/api/tax/returns/:taxYear/adjustments` | `type`, `description`, `amount` |
| DELETE | `/api/tax/returns/:taxYear/adjustments/:id` | 204 |
| PATCH | `/api/tax/returns/:taxYear/losses` | numeric `loss_carryforward_applied` |
| PATCH | `/api/tax/returns/:taxYear/payments` | numeric `tax_prepayments_made` |
| GET | `/api/tax/vat/overview` | query `year`, optional `period` |
| GET | `/api/tax/vat/:taxYear` | VAT periods |
| GET | `/api/tax/vat/:taxYear/:periodId` | VAT return detail |
| GET | `/api/tax/vat/:taxYear/:periodId/export` | XML download |
| PATCH | `/api/tax/vat/review/:invoiceId` | body `status` |

### Assets (`hasAssets`)

Use body/query/header company context. All require asset permissions.

| Method | Path | Input/use |
|---|---|---|
| GET | `/api/assets` | Filters: asset number/name/category/status/supplier/assignee/location |
| POST | `/api/assets` | Asset fields; generates number if absent |
| PATCH | `/api/assets/:id` | Asset patch |
| DELETE | `/api/assets/:id` | Refuses accounting-linked assets; dispose/archive instead |
| GET | `/api/assets/:id/history` | Change history |
| GET | `/api/assets/:id/dependencies` | Dependency counts |
| POST | `/api/assets/:id/dispose` | `method`, optional `sale_price` |
| GET/POST | `/api/assets/:id/maintenance` | Maintenance list/create |
| GET/POST | `/api/assets/categories` | Category list/create |
| GET | `/api/assets/:id/documents` | Signed URLs (about 10 minutes) |
| POST | `/api/assets/:id/documents` | multipart `file`, optional `document_type`; 50 MB |
| DELETE | `/api/assets/:id/documents/:docId` | Delete document |
| GET/POST | `/api/assets/depreciation-engine/classifications` | List/create |
| GET | `/api/assets/depreciation-engine/industries` | List |
| GET | `/api/assets/depreciation-engine/industries/paginated` | `classificationId`, `page`, `pageSize` |
| GET | `/api/assets/depreciation-engine/industries/search` | query `query` |
| POST/DELETE | `/api/assets/depreciation-engine/industries` | Create or delete IDs |
| POST | `/api/assets/depreciation-engine/industries/extract` | multipart PDF/text/CSV |
| GET | `/api/assets/depreciation-engine/assets` | Knowledge assets |
| DELETE | `/api/assets/depreciation-engine/assets` | body `{ ids: [] }` |
| GET | `/api/assets/depreciation-engine/search` | query `query` |
| POST | `/api/assets/depreciation-engine/import` | industry/source/version/assets payload |
| POST | `/api/assets/depreciation-engine/assets/extract` | multipart PDF/text/CSV |
| POST | `/api/assets/depreciation-engine/ai-suggest` | AI suggestion body |

Asset status values: `Active`, `Under Repair`, `Sold`, `Scrapped`, `Lost`, `Stolen`, `Archived`. Ownership values: `Owned`, `Operating Lease`, `Finance Lease`, `Rental`.

### Vehicles (`hasAssets`)

All require Auth and `x-company-id`. Most create payloads currently pass through to the database without a published schema, so use the backend migrations/model as source of truth before building each form.

| Method | Path | Input/use |
|---|---|---|
| GET/POST | `/api/vehicles` | List/create vehicles |
| GET | `/api/vehicles/:id` | Vehicle detail |
| GET | `/api/vehicles/dashboard` | Fleet stats |
| POST | `/api/vehicles/calculate-distance` | addresses or place IDs |
| GET/POST | `/api/vehicles/locations` | Locations |
| GET/POST | `/api/vehicles/locations/favorites` | Favorite locations |
| GET | `/api/vehicles/:vehicleId/trips` | Trips |
| POST | `/api/vehicles/trips` | Create trip; body includes vehicle ID |
| GET/POST | `/api/vehicles/drivers` | Drivers |
| POST | `/api/vehicles/:vehicleId/assignments` | `driver_id`, optional `is_primary` |
| GET/POST | `/api/vehicles/:vehicleId/fuel` | Fuel logs |
| POST | `/api/vehicles/:vehicleId/fuel-receipt` | multipart `file`; OCR, 50 MB |
| GET/POST | `/api/vehicles/:vehicleId/services` | Service logs |
| GET/POST | `/api/vehicles/:vehicleId/insurance` | Insurance |
| GET/POST | `/api/vehicles/:vehicleId/documents` | Document metadata (not multipart here) |
| GET | `/api/vehicles/:id/expenses` | Expenses |
| POST | `/api/vehicles/expenses` | Create expense; body includes vehicle ID |
| GET | `/api/vehicles/:id/profitability` | Profitability |
| GET/POST | `/api/vehicles/:vehicleId/mileage` | Mileage; business/mixed computes Kilometergeld |
| GET/POST | `/api/vehicles/settings` | `kilometergeld_rate` |

### Employees, consultants, GDPR, activities

| Method | Path | Auth | Input/use |
|---|---|---:|---|
| GET | `/api/companies/:companyId/employees` | Yes | Team list (`hasTeamAccess`, `user.manage`) |
| POST | `/api/companies/:companyId/employees/invite` | Yes | email, role, access level, custom permissions |
| PUT | `/api/companies/:companyId/employees/:employeeId` | Yes | role/access/status patch |
| DELETE | `/api/companies/:companyId/employees/:employeeId` | Yes | Remove |
| GET | `/api/invite/:token` | No | Employee invitation details |
| POST | `/api/invite/:token/accept` | No | `{ password }` |
| POST | `/api/account-access/register` | No | email, password, accounting role |
| GET/PATCH | `/api/account-access/me` | Yes | Consultant profile |
| GET | `/api/account-access/directory` | Yes | Professional directory |
| GET | `/api/account-access/companies` | Yes | Accessible companies |
| GET | `/api/account-access/my-clients` | Yes | `q`, `page`, `limit` |
| GET | `/api/account-access/companies/:companyId/employees` | Yes | Alias for employee list |
| POST | `/api/account-access/companies/:companyId/employees/invite` | Yes | Alias for employee invite |
| DELETE | `/api/account-access/companies/:companyId/employees/:employeeId` | Yes | Alias for employee removal; no PUT alias |
| GET/POST | `/api/account-access/companies/:companyId/assignments` | Yes | List/create assignments |
| PATCH/DELETE | `/api/account-access/companies/:companyId/assignments/:assignmentId` | Yes | Update/remove |
| GET/POST | `/api/account-access/companies/:companyId/invitations` | Yes | List/create consultant invitations |
| DELETE | `/api/account-access/companies/:companyId/invitations/:invitationId` | Yes | Delete pending invitation |
| GET | `/api/account-access/invite/:token` | No | Consultant invitation details |
| POST | `/api/account-access/invite/:token/accept` | No | `{ password }` |
| GET | `/api/account-access/gdpr/active` | Yes | query optional company; policy + acceptance |
| POST | `/api/account-access/gdpr/accept` | Yes | required `gdpr_text_id` (or `text_id`), optional `company_id` |
| GET | `/api/companies/:companyId/activities` | Yes | Last 100; team permission + `hasActivityLog` |

Accounting roles include accountant, tax adviser, CFO, controller, accounting manager, senior accountant, financial analyst/consultant, bookkeeper, AP/AR clerk, payroll administrator, and tax specialist.

### Mail integrations (`hasMail`)

| Method | Path | Company/input | Notes |
|---|---|---|---|
| GET | `/api/auth/google/url` | optional query `origin` | Returns authorization URL |
| GET | `/api/oauth/callback` | OAuth code/state | Google callback |
| GET | `/api/auth/outlook/url` | optional query `origin` | Returns authorization URL |
| GET | `/api/oauth/outlook/callback` | OAuth code/state | Microsoft callback |
| GET/DELETE | `/api/gmail/status` / `/api/gmail/disconnect` | optional company | Connection |
| GET | `/api/gmail/messages` | `q`, `pageToken`, `maxResults<=25`, optional company | Message summaries |
| GET | `/api/gmail/messages/:id` | ID | Full message |
| GET | `/api/gmail/messages/:id/attachments/:attachmentId` | IDs | Binary attachment |
| POST | `/api/gmail/send` | `to`, `subject`, `bodyText`, optional company | Send |
| POST | `/api/gmail/messages/:id/reply` | `to`, `subject`, `bodyText` | Reply |
| GET/DELETE | `/api/outlook/status` / `/api/outlook/disconnect` | optional company | Connection |
| GET | `/api/outlook/messages` | search/paging/company | Message summaries |
| GET | `/api/outlook/messages/:id` | ID | Message + PDF attachments |
| GET | `/api/outlook/messages/:id/attachments/:attachmentId` | IDs | Binary attachment |
| POST | `/api/outlook/send` | `to`, `subject`, `bodyText`, optional company | Send |
| POST | `/api/outlook/messages/:id/reply` | `bodyText` | Reply |
| GET/PUT/DELETE | `/api/email/config` | query/body `company_id` | Custom IMAP/SMTP config |
| GET | `/api/email/status` | query company | Custom connection status |
| POST | `/api/email/test` | company + IMAP/SMTP config | Test credentials |
| GET/PUT | `/api/email/provider` | company; provider gmail/outlook/custom | Selected provider |
| GET | `/api/email/messages` | company; date range/paging | IMAP messages |
| GET | `/api/email/messages/:id/attachments/:attachmentId` | company + IDs | Binary attachment |
| POST | `/api/email/send` | company, `to`, `subject`, `bodyText` | SMTP send |

Custom mail passwords are sent to the backend and encrypted at rest. Never persist them in ordinary mobile preferences or logs.

Custom mail configuration shape:

```ts
{
  company_id: number;
  imap: {
    host: string;
    port?: number;       // default 993
    secure?: boolean;    // default true
    user: string;
    pass: string;
    mailbox?: string;    // default INBOX
  };
  smtp: {
    host: string;
    port?: number;       // default 587
    secure?: boolean;    // default false/STARTTLS
    user: string;
    pass: string;
    from_email?: string;
    from_name?: string;
  };
}
```

`GET /api/email/config` never returns passwords; it returns `has_password` flags.

### Billing

| Method | Path | Auth | Input/use |
|---|---|---:|---|
| GET | `/api/stripe/plans` | No | Public plan catalog |
| GET | `/api/stripe/subscription/:companyId` | Yes | Owner subscription |
| POST | `/api/stripe/create-checkout-session` | Yes | `companyId`, `planId`, `billingInterval`, unique `requestId` |
| POST | `/api/stripe/create-portal-session` | Yes | `companyId` |
| POST | `/api/stripe/webhook` | Stripe | Server-to-server only; never call from app |

The app must not expose Founder or Accountant as purchasable plans (`checkoutEnabled` is false). Before shipping native billing, product/legal must decide whether the mobile app opens the existing web checkout/portal or implements store billing and entitlement synchronization. Do not silently launch Stripe Checkout from a native purchase button without that decision.

## 8. Files and storage

Private Supabase buckets include:

- `invoice-uploads`
- `offer-uploads`
- `asset-documents`
- `company-documents`

Use Express endpoints for uploads. Do not construct storage URLs or write directly to buckets. Signed URLs expire; cache the file bytes if the user needs offline access, not the URL. Validate MIME type from returned headers and do not trust filename extensions.

Upload summary:

| Use | Field | Limit | Types |
|---|---|---:|---|
| User avatar | `avatar` | 2 MB | JPEG, PNG, WebP |
| Company logo | `logo` | 2 MB | Middleware limit; client should send JPEG/PNG/WebP |
| Company document | `file` | 2 MB | PDF/text used by extraction |
| Catalog import | `file` | 10 MB | XLS/XLSX |
| Incoming invoice | `file` | 50 MB | PDF/JPEG/PNG/WebP/HEIC/HEIF |
| Asset document/extraction | `file` | 50 MB | Documents; extractors support PDF/text/CSV |
| Fuel receipt | `file` | 50 MB | PDF/JPEG/PNG/WebP/HEIC/HEIF |
| Bank statement | `file` | 50 MB | PDF/XML/OFX/XLS/XLSX/CSV |
| AI editor import/attachments | `file`/`files` | 25 MB | PDF/JPEG/PNG/WebP as applicable |
| Invoice/offer PDF send | `file` | Route middleware 2 MB for invoices; default Multer memory for offers | PDF expected |

HEIC/HEIF decoding depends on server image-library support. Keep a client-side JPEG conversion fallback.

## 9. Realtime and background behavior

`company_activities` is in the Supabase Realtime publication with RLS for company owners, employees, and active accounting assignments. The mobile app may subscribe directly using its Supabase user session:

- table: `company_activities`
- event: `INSERT`
- filter: `company_id=eq.<selectedCompanyId>`

Use `GET /api/companies/:companyId/activities` for the initial last-100 snapshot, then realtime for additions. Re-subscribe on company switch and unsubscribe on logout.

Other resources are not explicitly published for realtime in this repository. Use refresh-after-mutation and pull-to-refresh rather than assuming realtime updates.

Recurring invoices run in the Express process daily at 00:05 server time. The implementation currently has two important limitations: generated invoices do not visibly get an API push notification, and auto-send uses a placeholder recipient and no generated PDF. Keep `autoSendEmail` hidden/disabled on mobile until the backend fixes and verifies this flow.

There is no device-token, APNs, FCM, or general push-notification endpoint.

## 10. Mobile client example

Generic authenticated request:

```ts
async function api(path: string, init: RequestInit = {}, companyId?: number) {
  const { data } = await supabase.auth.getSession();
  const token = data.session?.access_token;
  if (!token) throw new Error("Not authenticated");

  const response = await fetch(`https://docelix.onrender.com${path}`, {
    ...init,
    headers: {
      Accept: "application/json",
      ...(init.body instanceof FormData ? {} : { "Content-Type": "application/json" }),
      Authorization: `Bearer ${token}`,
      ...(companyId ? { "x-company-id": String(companyId) } : {}),
      ...init.headers,
    },
  });

  if (response.status === 204) return undefined;
  const contentType = response.headers.get("content-type") || "";
  const body = contentType.includes("application/json")
    ? await response.json()
    : await response.arrayBuffer();

  if (!response.ok) {
    const message = body?.error ?? body?.message ?? `Request failed (${response.status})`;
    throw Object.assign(new Error(message), { status: response.status, body });
  }
  return body;
}
```

Example list call:

```ts
const invoices = await api(
  `/api/invoices?company_id=${encodeURIComponent(String(companyId))}`,
  {},
  companyId,
);
```

Example multipart upload: append text values as strings and do not manually set the multipart `Content-Type`; the networking library must add the boundary.

## 11. Required backend/mobile decisions before release

### Blockers

1. **Provide a real staging environment.** Mobile QA must not use production data.
2. **Publish the mobile auth configuration.** Provide staging/production Supabase URL + anon/publishable key, allowed redirect URLs, email confirmation/reset rules, and test users.
3. **Add in-app account deletion.** No authenticated account-deletion endpoint exists. Company deletion is not user/account deletion.
4. **Implement native OAuth completion for Gmail and Outlook.** Current callbacks send JavaScript to `window.opener` and close a web popup. They do not redirect to an app universal link/custom scheme or provide a server-verifiable polling result.
5. **Choose the native subscription flow.** Define StoreKit/Play Billing versus approved web account-management behavior, and how store purchases update `subscriptions`.
6. **Fix recurring invoice auto-send** before exposing it: placeholder recipient, missing PDF, and no push notification.
7. **Reconcile payables data source.** Accounting payables reads `incoming_invoices`, while receipt upload/list uses `invoice_attachments`; mobile results may disagree or be empty.

### Strongly recommended API work

- Add `/api/v1` versioning and an OpenAPI document generated/tested in CI.
- Add `/health` and a build/version endpoint.
- Standardize response and error envelopes, including validation details and request IDs.
- Add consistent cursor/page pagination to all unbounded lists (invoices, clients, catalog, offers, assets).
- Add detail endpoints for invoices, clients, catalog items, and assets; today several screens must find the row in a list and make separate item calls.
- Add rate limiting, especially to public registration/invitation and AI/OCR endpoints.
- Add idempotency keys for invoice/payment/upload/email mutations.
- Return 413 consistently for Multer size errors instead of the generic 500 handler.
- Review direct RLS policies before enabling any additional mobile direct-table access. Keep normal business CRUD behind Express meanwhile.
- Add structured request logging/monitoring and redact tokens, mail credentials, OCR text, and financial documents.
- Define cache headers/ETags and an offline sync conflict strategy.
- Add device registration and push events if reminders, invitations, recurring invoices, or approvals need notifications.

## 12. Known behavior and integration cautions

- The API is unversioned and production deploys from `main`; coordinate mobile releases with backend changes.
- Core response shapes are inconsistent. Decode endpoint-specific DTOs rather than a single generic `data` wrapper.
- Several modules distinguish owner access from employee/read access. A feature may work for an owner but return 403 for an employee even when navigation is visible; test every supported role.
- The server uses a service-role Supabase client, so Express authorization middleware is the security boundary. Never omit company context, even if an endpoint appears to work without it.
- A 402 can come from a feature gate or monthly incoming-invoice quota. Show an upgrade/limit UI, not a generic network error.
- Email and AI/OCR calls depend on third parties and can take longer or fail independently of the core database.
- Company/logo and avatar endpoints return binary bytes, not JSON.
- XML VAT export and attachment endpoints return binary/text downloads; inspect `Content-Type` and `Content-Disposition`.
- There is no documented server-side timezone setting. Keep financial dates as calendar dates and avoid converting `YYYY-MM-DD` through local-time `Date` objects.
- The public plan copy and enforcement should be product-reviewed: the Starter copy mentions core accounting while current `hasFinance` enforcement is false.

## 13. Backend source map

- Application mounts: `src/app.ts`
- Server/worker start: `src/server.ts`
- JWT auth: `src/auth/auth.ts`
- RBAC/permissions: `src/middlewares/rbac.middleware.ts`, `src/models/common/ownership.ts`
- Plan gates: `src/middlewares/plan.middleware.ts`, `src/models/common/planLimits.ts`
- Main routes: `src/routes/**`, `src/routers/**`, `src/modules/**/routes*`
- Core controllers: `src/controllers/**`
- Core models/DTO hints: `src/models/**`, `src/types/**`
- Database history/RLS/storage: `supabase/migrations/**`
- Local Supabase/Auth config: `supabase/config.toml`
- Production/staging deployment declaration: `render.yaml`

When an endpoint payload is not fully typed—especially vehicles and advanced depreciation operations—confirm it against the matching controller, model, and latest migration before implementing the screen.
