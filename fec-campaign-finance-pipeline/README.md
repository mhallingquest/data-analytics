# FEC Campaign Finance Pipeline

A complete, working pipeline built on real, current-cycle federal campaign
finance data — raw CSV → BigQuery → dbt (staging + production marts) →
Power BI dashboard. Chosen specifically for the 2026 midterm election
cycle: this is genuinely live, up-to-date data, not a historical or sample
dataset.

## Data source

**FEC candidate summary file (2025-2026 cycle)**, downloaded directly from:
https://www.fec.gov/data/browse-data/?tab=bulk-data (under "Candidates" →
"Candidate summary")

Direct link: https://www.fec.gov/files/bulk-downloads/2026/candidate_summary_2026.csv

This is official, legally-mandated federal disclosure data — complete by
design (no privacy-driven field stripping like the earlier GA4 attempt hit).
One row per candidate registered for U.S. House, Senate, or President in
the current cycle, with financial totals updated as new filings come in.

**A note on the data itself:** many candidates legitimately show $0 across
every financial field. This isn't missing or stripped data — it's simply
true that most declared candidates, especially early in a cycle or in
uncompetitive races, haven't raised or spent anything yet. Worth mentioning
in the dashboard write-up so it doesn't read as a pipeline bug.

## Pipeline architecture

```
fec.gov (candidate_summary_2026.csv)
    → BigQuery (direct upload, no Cloud Storage needed)
    → dbt staging model (clean/rename/type-cast)
    → dbt mart models (fundraising by party/office, candidate leaderboard)
    → Power BI (connects to BigQuery marts)
```

## Setup

### 1. Download the CSV

Direct link (updates regularly as new filings come in, so re-download for
the latest data):
https://www.fec.gov/files/bulk-downloads/2026/candidate_summary_2026.csv

### 2. Upload directly into BigQuery

1. Create a dataset: three-dot menu next to your project → **Create dataset** → name it `fec_raw`
2. Three-dot menu next to `fec_raw` → **Create table**
3. Source: **Upload** → browse to the CSV
4. Table name: `candidate_summary_raw`
5. Schema: check **Auto detect**
6. Create Table

### 3. Set up dbt

Add the profile from `profiles.yml.example` into your existing
`~/.dbt/profiles.yml` as a fourth named block, filling in your real
project ID and keyfile path (same key file already used for your other
three pipelines works fine here too).

Update `models/staging/_staging__sources.yml`'s `database:` to your real
project ID.

### 4. Run it

```bash
dbt run
dbt test
```

### 5. Connect Power BI

Same pattern as the other three: Get Data → Google BigQuery → sign in →
Navigator → select `mart_fundraising_by_party_office` and
`mart_candidate_leaderboard` → Load (Import mode).

## Dashboard ideas this data supports well

- **Fundraising by party** — which party is raising more overall this cycle
- **House vs. Senate vs. Presidential fundraising** — office-type comparison
- **Top fundraisers leaderboard** — filterable by state, party, office
- **Self-funding vs. individual contributions** — which candidates are
  bankrolling their own campaigns vs. relying on donors
- **Incumbent vs. challenger vs. open-seat fundraising** — a genuinely
  interesting structural story (incumbents typically vastly outraise challengers)

## Refreshing with newer data

Since this is a live, ongoing election cycle, the source file updates
regularly. To refresh: re-download the CSV, re-upload (overwriting
`candidate_summary_raw`, or loading to a new table and repointing the
source), then `dbt run` again. Worth deciding whether you want a
point-in-time snapshot for the portfolio piece, or to periodically refresh
it as the election approaches — either is a reasonable choice, just worth
being intentional about which.
