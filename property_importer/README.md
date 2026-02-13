# Property & Unit CSV Importer

An internal-user-facing Rails tool for importing properties and units from a CSV into production. Guided by the [design spec](../BUILD.md).

Built by @mcarlssen for the Payscore Technical Operations Engineer assessment.

---

## How to run locally

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

Load the baseline seed data:

```bash
bundle exec rails db:seed_baseline
```

If that task fails, you can load the SQL file directly (replace with your DB name/user if different):

```bash
psql -U postgres -d property_importer_development -f db/seeds_baseline_dev.sql
```

Load sample staged rows (optional — creates a draft import session with rows from `Sample_Import.csv`, as well as examples of prior import history):

```bash
bundle exec rails db:seed_staged_rows
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

1. On the home page, click “Choose File” and select a CSV with columns: **Building Name, Street Address, Unit, City, State, Zip Code** (see `Sample_Import.csv` in the project root).
2. Click “Upload and continue” → you’re on **Preview Import**. Edit any cell and click “Save changes” if you want.
3. Click “Next: Deduplication” → if the CSV matches existing properties, you can skip units or skip the whole property.
4. Click “Next: Summary” then **Confirm import** → data is written to the database.
5. Use **Properties** in the nav to see the list and open a property to see its units.

### 7. Stop the server

In the terminal where the server is running, press **Ctrl+C**.

---

## Additional documentation

- **[Build spec](BUILD.md):** Formal outline of project requirements, design decisions, etc.
- **[Ideation](thoughts.md):** "Stream-of-consciousness" thought process diary as I considered this assignment.