# NBA Team Stats Pipeline

A complete, working pipeline built on real NBA team game data — raw CSV →
BigQuery → dbt (staging + production marts) → Power BI dashboard, covering
regular season games from 2010 through 2024.

## Data source

**NocturneBear/NBA-Data-2010-2024** on GitHub:
https://github.com/NocturneBear/NBA-Data-2010-2024

Publicly hosted, actively maintained (updated twice a year, after the
regular season and after the playoffs), fully documented column schema in
the repo's own README — no Kaggle login, no API key required. The author
explicitly built this dataset for exactly this workflow (their own README
states they upload it to BigQuery and analyze it with SQL).

**File used:** `regular_season_totals_2010_2024.csv` (~8.7MB) — one row
per team per game (each game produces two rows, one for each team).

Direct download:
https://github.com/NocturneBear/NBA-Data-2010-2024/raw/refs/heads/main/regular_season_totals_2010_2024.csv

## Pipeline architecture

```
GitHub (regular_season_totals_2010_2024.csv)
    → BigQuery (direct upload, no Cloud Storage needed at this size)
    → dbt staging model (clean/rename/type-cast)
    → dbt mart models (team season summary, league shooting trends)
    → Power BI (connects to BigQuery marts)
```

## Setup

### 1. Download the CSV
From the direct link above.

### 2. Upload directly into BigQuery

1. Create a dataset: three-dot menu next to your project → **Create dataset** → name it `nba_raw`
2. Three-dot menu next to `nba_raw` → **Create table**
3. Source: **Upload** → browse to the CSV
4. Table name: `team_game_totals_raw`
5. Schema: check **Auto detect**
6. Create Table

### 3. Set up dbt

Add the profile from `profiles.yml.example` into your existing
`~/.dbt/profiles.yml` as a fifth named block, filling in your real project
ID and keyfile path (same key file already used for your other pipelines
works fine here too).

Update `models/staging/_staging__sources.yml`'s `database:` to your real
project ID.

### 4. Run it

```bash
dbt run
dbt test
```

### 5. Connect Power BI

Same pattern as your other pipelines: Get Data → Google BigQuery → sign in
→ Navigator → select `mart_team_season_summary` and
`mart_league_shooting_trends` → Load (Import mode).

## Dashboard ideas this data supports well

- **Team win percentage by season** — track a franchise's performance
  trajectory over the 2010-2024 span
- **The 3-point revolution** — `mart_league_shooting_trends` shows league-
  wide 3-point attempt volume climbing sharply across these seasons, one
  of the most well-documented tactical shifts in modern NBA history
- **Offense vs. defense** — average points scored vs. average point
  differential, by team and season
- **Shooting efficiency comparison** — field goal %, 3-point %, free
  throw % side by side across teams

## A note on grain

This mart is built at the **team-season** level, not individual games or
individual players. If you want game-by-game or player-level detail later,
the same GitHub repo has `regular_season_box_scores_2010_2024_part_1/2/3.csv`
(player-level, split into three files due to size — likely needs the
Cloud Storage upload path rather than direct upload, given the larger
volume) as a natural next step.
