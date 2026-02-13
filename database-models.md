# Database models

Reference schema for the Property & Unit CSV importer. Used by [BUILD.md](BUILD.md).

---

## Production tables

### properties

| Column          | Type         | Constraints |
|-----------------|--------------|-------------|
| id              | bigint       | PK, auto    |
| building_name   | string       | NOT NULL    |
| street_address  | string       | NOT NULL    |
| city            | string       | NOT NULL    |
| state           | string       | NOT NULL    |
| zip_code        | string       | NOT NULL    |
| created_at      | datetime     | NOT NULL    |
| updated_at      | datetime     | NOT NULL    |

**Uniqueness:** `(building_name, street_address, city, state, zip_code)` — one property per distinct building + full address. This avoids treating "Avenue Apartments" in two cities as the same property.

**Index:** Unique index on `[building_name, street_address, city, state, zip_code]` for fast lookup during conflict detection.

---

### units

| Column       | Type     | Constraints |
|--------------|----------|-------------|
| id           | bigint   | PK, auto    |
| property_id  | bigint   | NOT NULL, FK → properties.id |
| unit_number  | string   | NOT NULL    |
| created_at   | datetime | NOT NULL    |
| updated_at   | datetime | NOT NULL    |

**Uniqueness:** `(property_id, unit_number)` — one unit per unit number per property.

**Index:** Unique index on `[property_id, unit_number]`. Index on `property_id` for associations.

**Note:** Rows in the CSV with an empty Unit do not create a Unit record; they create only a Property (see BUILD.md Decisions).

---

## Staged / import tables

Staged data lives in these tables until the user confirms the import. Production is never written until confirm.

### import_sessions

| Column       | Type     | Constraints |
|--------------|----------|-------------|
| id           | bigint   | PK, auto    |
| status       | string   | NOT NULL, e.g. `draft` \| `committed` \| `failed` |
| file_name    | string   | optional, original CSV name |
| created_at   | datetime | NOT NULL    |
| updated_at   | datetime | NOT NULL    |

**Purpose:** One session per import flow. Status prevents double-commit (idempotent confirm). `committed` = import finished; `draft` = in progress; `failed` = confirm failed, user can retry.

---

### staged_rows

One row per CSV data row (after header). Allows inline edit by row and accurate error reporting by line number.

| Column          | Type    | Constraints |
|-----------------|---------|-------------|
| id              | bigint  | PK, auto    |
| import_session_id | bigint | NOT NULL, FK → import_sessions.id |
| row_number      | integer | NOT NULL    | 1-based CSV line number |
| building_name   | string  | NOT NULL    |
| street_address  | string  | NOT NULL    |
| unit_number     | string  | nullable    | empty string or NULL = property-only row |
| city            | string  | NOT NULL    |
| state           | string  | NOT NULL    |
| zip_code        | string  | NOT NULL    |
| validation_errors | text   | nullable    | e.g. JSON array of `{field, message}` or comma-separated |
| created_at      | datetime | NOT NULL   |
| updated_at      | datetime | NOT NULL   |

**Uniqueness:** None required on staged_rows; duplicates are allowed until the user resolves them in the UI. Property/unit uniqueness is enforced when mapping to production (see BUILD.md Business rules).

**Index:** `import_session_id` for fast scope of "all rows in this import."

**Note:** User edits (inline or bulk) update `staged_rows`; autosave on blur or on "Next" so work is not lost.

---

## Entity relationship (conceptual)

- **Production:** `Property` 1 — * `Unit` (property has many units).
- **Staged:** `ImportSession` 1 — * `StagedRow` (session has many rows). Staged rows are grouped in app logic by `(building_name, street_address, city, state, zip_code)` to form "staged properties" and their units for conflict resolution and summary.

---

## Lookups used in the app

1. **Property identity (production):** `Property.find_by(building_name:, street_address:, city:, state:, zip_code:)`.
2. **Property identity (staged):** Group `StagedRow` by `[building_name, street_address, city, state, zip_code]`; each group is one "staged property" with N units (rows with non-blank `unit_number`).
3. **Conflict detection:** For each staged property (group), look up existing `Property` by same composite. If found → conflict; user chooses add new units / skip property. Unit-level: for that property, existing units are `Unit.where(property_id: existing.id)`; staged units are the group’s rows with `unit_number` present. Duplicate unit numbers (staged vs existing) → user resolves (keep one / skip / etc.) at unit level.
