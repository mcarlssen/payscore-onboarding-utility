# Property & Unit CSV Importer

Internal Rails tool for importing properties and units from a CSV. Built per [BUILD.md](../BUILD.md) and [database-models.md](../database-models.md).

---

## How to run locally (Rails beginners)

### 1. Prerequisites

- **Ruby** 3.1+ (check: `ruby -v`)
- **PostgreSQL** installed and running (check: `psql -U postgres -c "SELECT 1"` or use a GUI like pgAdmin)
- **Bundler**: `gem install bundler` if you don’t have it

### 2. One-time setup

Open a terminal and go to the app folder:

```bash
cd property_importer
```

Install Ruby dependencies:

```bash
bundle install
```

Create the database and run migrations:

```bash
bundle exec rails db:create
bundle exec rails db:migrate
```

Load the baseline seed data (3 properties, 7 units for “Avenue Apartments”):

```bash
bundle exec rails db:seed_baseline
```

If that task fails, you can load the SQL file directly (replace with your DB name/user if different):

```bash
psql -U postgres -d property_importer_development -f db/seeds_baseline.sql
```

### 3. Configure the database (if needed)

If PostgreSQL uses a different user, password, or host, edit `config/database.yml` and set `username`, `password`, and `host` for the `development` section.

### 4. Start the app

From the `property_importer` folder:

```bash
bundle exec rails server
```

Or the short form:

```bash
bundle exec rails s
```

You should see something like: `Listening on http://0.0.0.0:3000` or `http://127.0.0.1:3000`.

### 5. Open the app in a browser

- **URL:** [http://localhost:3000](http://localhost:3000)
- **Home:** Upload CSV (step 1)
- **Properties:** List of all properties after import

### 6. Try an import

1. On the home page, click “Choose File” and select a CSV with columns: **Building Name, Street Address, Unit, City, State, Zip Code** (see `Payscore Property CSV Import Example - Properties.csv` in the assessment folder).
2. Click “Upload and continue” → you’re on **Preview Import**. Edit any cell and click “Save changes” if you want.
3. Click “Next: Deduplication” → if the CSV matches existing properties, you can skip units or skip the whole property.
4. Click “Next: Summary” then **Confirm import** → data is written to the database.
5. Use **Properties** in the nav to see the list and open a property to see its units.

### 7. Stop the server

In the terminal where the server is running, press **Ctrl+C**.

---

## Assumptions and tradeoffs

- **Property unique identifier:** Building name + full address `(building_name, street_address, city, state, zip_code)`. Same name in different cities = different properties.
- **Empty Unit:** Rows with blank Unit create a **Property only**; no Unit record.
- **No auth / no multi-tenancy:** Internal tool, single user; no login or tenant scoping.
- **No delete in MVP:** Cannot delete units or properties from this tool.
- **Duplicates and conflicts:** Always shown to the user; no automatic removal. User chooses per unit (skip/keep) or per property (skip entire property / add new units).

---

## How duplicates and conflicts work

- **Staged grouping:** Rows are grouped by `(building_name, street_address, city, state, zip_code)`. Each group is one “staged property” with N units (rows that have a non-blank Unit).
- **DB lookup:** For each staged property we look up an existing **Property** by the same composite. If found → conflict.
- **Resolution:** User can “Skip this entire property” or “Add new units.” For units that already exist on the existing property, user can “Skip this unit” so it is not imported. No silent overwrites.

---

## What we’d improve (Phase 2)

- **Immutability / forensics:** Append-only writes with timestamps; soft delete so support can explain “what happened.”
- **Resume from row N:** For large files, allow fixing a row and re-running import from that row to the end.
- **Deleting units or properties:** Separate flow or CSV column, with safeguards.
- **Address normalization:** Optional normalization for address fields only (e.g. “Avenue” → “Ave”), or USPS/UPS lookup with user confirmation; building name stays as-is.
- **Configurable validation rules:** e.g. YAML/JSON so business rules can change without code changes.
- **Large files:** Virtualized list or “Show first N rows” + “Show more” / export full list to avoid rendering 2000+ rows in the DOM.

---

## Routes overview

| Path | Purpose |
|------|--------|
| `GET /` | Upload CSV (step 1) |
| `POST /imports` | Create import session and parse CSV |
| `GET /imports/:id/preview` | Preview Import (step 2) |
| `PATCH /imports/:id/preview_update` | Save edits to staged rows |
| `GET /imports/:id/conflicts` | Resolve conflicts (step 3) |
| `PATCH /imports/:id/conflicts_resolve` | Save conflict choices |
| `GET /imports/:id/summary` | Summary & confirm (step 4) |
| `POST /imports/:id/confirm` | Commit import to production |
| `GET /properties` | List properties |
| `GET /properties/:id` | Show property and its units |
