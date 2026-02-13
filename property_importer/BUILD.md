# Property & Unit CSV Importer — Build spec

Spec for building the Technical Operations Engineer take-home: a Ruby on Rails internal tool that lets customer success upload a property spreadsheet, sanity-check and fix data, avoid duplicates, and finalize imports confidently. This document is the single source of truth for architecture, business rules, UI design, and build plan. Schema details live in [database-models.md](database-models.md).

---

## 1. Overview and goals

**Objective:** A small Ruby on Rails app for internal users - and arguably external users - to import properties and units from CSV. The CSV format is fixed (see example in repo). The tool should make it easy to:

- Upload a CSV and see what the system will import
- Catch and fix obvious mistakes before anything is permanently saved
- Avoid importing the same property (or unit) more than once
- Feel confident when finalizing an import

**Scope:** MVP is internal tool only. No authentication to production database. UI can be simple and unpolished. The intent is to demonstrate thoughtful handling of data, reducing deduplication risk, and clear user communication.

---

## 2. Decisions and assumptions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Empty Unit** | Rows with blank Unit create a **Property only**; no Unit record is created. | A property owner could be renting a single-family residence where "unit" is superfluous. This function also supports importing additional units later as an update. |
| **Property unique identifier** | **Building name + full address** `(building_name, street_address, city, state, zip_code)`. | The assessment says building name *can be* the unique identifier, not *must be*. There are many scenarios where name-only deduplication is not enough to ensure uniqueness. For example, the same building name in different cities (e.g. "Avenue Apartments" in Seattle vs Boston) must be different properties. Using name+address as the composite key removes ambiguity and eliminates the "same name, different city" auto-dedupe risk. |
| **Unit-level deduplication** | Uniqueness is enforced at **unit level** within a property: `(property_id, unit_number)`. Conflict resolution in MVP supports **unit-level** choices (e.g. keep / skip per unit), not only property-level. | Adding unit to the unique check is minimal extra work and gives clearer, safer behavior when the same unit appears in CSV and DB. |
| **Building name normalization** | **Light normalization** (strip, uppercase, remove all punctuation **except dash and apostrophe**) for all fields including building name when matching. No semantic canonicalization (e.g. "Avenue" → "Ave") on building name. | Light normalization helps match variations like "Avenue Apartments" vs "Avenue Apartments." (trailing punctuation). Apostrophe is preserved for names (e.g. O'Brien). Semantic canonicalization could incorrectly merge different buildings; avoid for building name. Address fields may get semantic normalization in a future phase. |
| **Duplicate resolution** | **Always surface duplicates and conflicts to the user.** No automatic removal of “duplicate" rows without explicit user choice (keep / delete / delete all, or add units / skip property). | Ensures the user stays in control and avoids wrong merges. |
| **MVP scope** | No versioning/immutability, no “resume from row N," no support for deleting units or properties. | Keep MVP shippable. These are documented as “what we’d improve" for the assessment. |

---

## 3. Architecture

- **Stack:** Ruby on Rails, PostgreSQL. Relational DB for both production and staged data.
- **Data split:**  
  - **Production:** `properties`, `units` — only written when the user confirms the import.  
  - **Staged:** `import_sessions`, `staged_rows` — hold the current import in progress; all edits and validation target staged data until confirm.
- **Flow:** Upload → parse into `staged_rows` under an `ImportSession` → user moves through steps (Preview Import → Resolve conflicts → Summary) → single “Confirm import" writes from staged to production inside one DB transaction. On failure, transaction rolls back; staged data remains so the user can fix and retry.
- **Idempotent confirm:** After a successful commit, set session status to `committed` (or equivalent) and refuse a second commit for that session. Disable the Confirm button after first click to avoid double submit.

High-level flow:

```
Upload CSV → Parse → Staged rows (edit/validate) → Conflict resolution → Summary → Confirm → Production
                     ↑___________________________________________________________|
                                      (all edits autosave to staged)
```

---

## 4. Data model summary

- **Production:** See [database-models.md](database-models.md).  
  - **Property:** Identified by `(building_name, street_address, city, state, zip_code)`; unique index on that composite.  
  - **Unit:** `(property_id, unit_number)` unique; belongs to Property.
- **Staged:**  
  - **ImportSession:** One per import; `status` (e.g. draft / committed / failed), optional `file_name`.  
  - **StagedRow:** One row per CSV data line; columns mirror CSV (building_name, street_address, unit_number, city, state, zip_code) plus `import_session_id`, `row_number`, optional `validation_errors`. No uniqueness on staged_rows; duplicates are resolved in the UI before commit.

---

## 5. Business rules

### 5.1 CSV format and required fields

- **Columns (expected):** Building Name, Street Address, Unit, City, State, Zip Code.
- **Required:** Building Name, Street Address, City, State, Zip Code. **Unit is optional.**
- **Empty Unit:** Treated as property-only; create one Property, zero Units.
- **Validation (MVP):** Reject or flag rows with missing required fields. Optional: zip format (e.g. 5 or 9 digits), state format (e.g. 2-letter or full name as in example). Document where to extend (e.g. model validations or a config).

### 5.2 Duplicate and conflict logic

- **In-CSV grouping:** Rows are grouped by `(building_name, street_address, city, state, zip_code)`. Each group is one “staged property" with N units (rows that have a non-blank unit_number). Identical rows (same property + same unit_number + same address) are treated as duplicates; surface them and let the user choose keep / delete / delete all.
- **DB lookup:** Property identity in the database is the same composite: `(building_name, street_address, city, state, zip_code)`. For each staged property (group), look up an existing Property by that composite. If found → conflict.
- **Conflict resolution:**  
  - **Property level:** User can choose “Add new units to existing property" or “Skip this property."  
  - **Unit level:** For “Add new units," compare staged unit numbers to existing `Unit` records for that property. If a unit number already exists, let the user choose per unit (e.g. skip this unit / keep as new only if different). No silent overwrites; show “Existing: X units. Import adds: Y units. After import: Z units."
- **No auto-removal:** Never remove or merge rows the system considers “duplicate" without explicit user action.

### 5.3 Validation and errors

- Parse errors (e.g. bad encoding, unparseable CSV): Show message and, if possible, line number; optional “Download errors CSV" (row, column, message).
- Row-level validation: Required fields, format rules. Display errors by row number; allow “Download errors CSV." “Next" can require no blocking errors or allow “Next with errors" and re-validate at confirm; document the chosen behavior.

---

## 6. UI design

- **Multi-step layout:** Linear steps with one primary CTA per step. Steps: (1) Upload, (2) Preview Import, (3) Resolve conflicts, (4) Summary & confirm.
- **Progress indicator:** Stepper or tracker (e.g. Upload → Preview → Conflicts → Confirm) so users know where they are and can go back.
- **Preview Import:** Table of staged rows (all CSV columns). Inline edit with autosave to `staged_rows`; show “Saved" or checkmark on blur. Validation errors per row (e.g. inline or tooltip). Bulk actions where useful: “Accept all" / “Reject all" per category (e.g. address corrections, duplicate choices).
- **Conflict resolution:** For each conflict, show existing vs staged (e.g. side-by-side or clear summary). “Existing: 5 units. Import adds: 3 units. After import: 8 units." Unit-level choices where applicable (keep / skip per unit). Bulk: e.g. “Add all new units to existing properties."
- **Summary before confirm:** Explicit counts, e.g. “You’re about to add **3 new properties** (12 units) and **2 existing properties** (5 new units). [Confirm import]." Single primary button: “Confirm import." On success → redirect to “Import complete" or property list; on failure → show error, keep staged data, allow Retry.
- **Large files:** Avoid rendering 2000+ rows in the DOM at once. Use virtualized list, or show first N rows (e.g. 200) with “Show more" / “Export full list," and indicate “Showing 1–200 of 2000." Document as a tradeoff in README.

---

## 7. User flow (step-by-step)

| Step | Purpose | What’s shown | Primary action | Data |
|------|---------|--------------|----------------|------|
| **1. Upload** | Ingest CSV | File input; after parse: success or error message (+ optional error CSV) | “Upload" / “Next" | Parse into `staged_rows` for new `ImportSession` |
| **2. Preview Import** | Edit and validate | Table of staged rows; inline edit; validation errors by row | “Next" | All edits autosave to `staged_rows` |
| **3. Deduplication** | Match staged vs existing | List of conflicts (staged property already in DB); per-property and per-unit choices | “Add units" / “Skip" (and unit-level); “Next" | Read from `staged_rows` + production `properties`/`units` |
| **4. Summary & confirm** | Final check and commit | Counts (new properties, new units, existing updated); single Confirm | “Confirm import" | Single transaction: staged → production; session status → committed |

- **Back:** User can go back to previous steps without losing edits (all in staged).
- **Failure on confirm:** Transaction rollback; show error and “Retry"; staged data unchanged.

---

## 8. Build plan

### 8.1 MVP (Phase 1)

- Upload CSV; parse into `import_sessions` + `staged_rows`.
- Steps: Upload → Preview Import → Resolve conflicts → Summary → Confirm.
- Validation: Required fields; optional format rules (zip, state). Errors by row; optional error CSV download.
- Property identity: `(building_name, street_address, city, state, zip_code)` in both staged grouping and production lookup.
- Unit-level dedup and conflict resolution: User can choose keep/skip per unit when adding to an existing property.
- Single transaction on confirm; idempotent confirm (disable button / session status).
- No versioning, no “resume from row N," no delete of units or properties. No USPS/UPS or external address APIs.

### 8.2 Phase 2 / “What we’d improve" (for README)

- **Immutability / forensics:** Append-only writes with timestamp; soft delete via `is_valid` (or equivalent) so nothing is lost and support can explain “what happened."
- **Resume from row N:** If parse or validation fails partway through a large file, let the user fix the row and re-run import from that row to the end.
- **Deleting units or properties:** Not in MVP; could add via a column in the CSV or a separate flow, with safeguards.
- **Address normalization:** Optional internal normalization (e.g. “Avenue" → “Ave") or USPS/UPS lookup with user confirmation; only for address fields, not building name.
- **Configurable validation rules:** e.g. YAML/JSON so business rules can change without code changes.

---

## 9. Technical implementation notes

- **Rails:** Use a recent stable version; PostgreSQL for all environments.
- **CSV storage:** Either attach the file to `ImportSession` (e.g. Active Storage) for audit, or only persist parsed data in `staged_rows`; document the choice.
- **Confirm:** One ActiveRecord transaction: create/update `properties` and `units` from staged data, then set `import_sessions.status = 'committed'`. On exception, rollback and set status to `failed` (or leave `draft`) so user can retry.
- **No auth / no multi-tenancy:** Single user; no scoping by tenant or user.
- **Styling:** CSS theme from https://colorffy.com/dark-theme-generator?colors=cb770f-121212&success=22946E&warning=A87A2A&danger=9C2121&info=21498A&primaryCount=6&surfaceCount=6

---

## 10. README requirements

The app README must include:

- **How to run locally:** Clone, `bundle install`, `rails db:create db:migrate`, `rails server` (and any other steps).
- **Assumptions and tradeoffs:** Property unique identifier = building name + full address (and why); empty Unit = property-only; no auth; no delete in MVP.
- **How duplicates and conflicts are identified and resolved:** Composite key (name + address); unit-level uniqueness; user always chooses (no auto-remove).
- **What you’d improve:** Items from Phase 2 (immutability, resume from row N, delete support, address normalization, configurable rules).

---

## 11. Pitfalls (implementation reminders)

- **Do** use **building name + full address** as the property key everywhere (staged grouping, DB lookup, conflict resolution). Do not use building name alone.
- **Do not** auto-remove rows considered “duplicate" without user confirmation.
- **Do** use light normalization (strip, uppercase, punctuation) for all fields including building name when matching; do not add semantic canonicalization (e.g. Ave → Avenue) to building name.
- **Do** support unit-level conflict resolution in MVP (keep/skip per unit when adding to existing property).
- **Do** handle parse and validation errors with row-level messages and optional error CSV export.
- **Do** make confirm idempotent and transactional so a failed or repeated click doesn’t corrupt data.
