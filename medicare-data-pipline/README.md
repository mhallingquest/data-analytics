# Medicare Data Pipeline — Raw Data to Production Dashboard

A real, working data pipeline: raw CMS Medicare provider/service data →
Google Cloud Storage → BigQuery → dbt (staging + production models) →
Power BI dashboard. Built to demonstrate cloud-native data engineering
(BigQuery, dbt) end to end, using fully de-identified, public-domain
healthcare data — no PII, no HIPAA concerns.

## Data source

**Medicare Physician & Other Practitioners - by Provider and Service**,
published by CMS at:
https://data.cms.gov/provider-summary-by-type-of-service/medicare-physician-other-practitioners/medicare-physician-other-practitioners-by-provider-and-service

This dataset provides information on use, payments, and submitted charges
organized by National Provider Identifier (NPI), HCPCS procedure code, and
place of service — de-identified, aggregate data, safe for public use.

Download the CSV directly from that page (look for the "Detailed Data" /
"By Provider and Service" download link — file is typically several hundred
MB, released annually).

## Pipeline architecture

```
data.cms.gov (raw CSV)
    → Google Cloud Storage (raw landing zone)
    → BigQuery (raw table, loaded as-is)
    → dbt staging model (clean/rename/type-cast)
    → dbt mart models (provider summary, procedure summary)
    → Power BI (connects directly to BigQuery mart tables)
```

## Step-by-step setup

### 1. Land the raw file in Cloud Storage

```bash
# Create a bucket (skip if you already have one for this project)
gsutil mb -l US gs://your-bucket-name-medicare-raw

# Upload the downloaded CSV
gsutil cp MUP_PHY_R25_P05_V10_D23_Prov_Svc.csv gs://your-bucket-name-medicare-raw/
```

### 2. Load into BigQuery as a raw table

```bash
bq mk medicare_raw   # creates the dataset if it doesn't exist

bq load \
  --autodetect \
  --source_format=CSV \
  --skip_leading_rows=1 \
  your-gcp-project-id:medicare_raw.provider_service_raw \
  gs://your-bucket-name-medicare-raw/MUP_PHY_R25_P05_V10_D23_Prov_Svc.csv
```

`--autodetect` gets you moving quickly; for a production pipeline you'd
normally define an explicit schema instead of relying on autodetection,
but for a portfolio piece this is a reasonable tradeoff to call out if asked.

### 3. Set up dbt

```bash
pip install dbt-bigquery

# Authenticate (easiest for local dev)
gcloud auth application-default login

# Copy profiles.yml.example to where dbt expects it, and fill in your project id
mkdir -p ~/.dbt
cp profiles.yml.example ~/.dbt/profiles.yml
# edit ~/.dbt/profiles.yml: replace 'your-gcp-project-id' with your real project

# Also update the source() database in models/staging/_staging__sources.yml
# to your real project id
```

### 4. Run the pipeline

```bash
dbt run
dbt test
```

`dbt run` builds `stg_medicare_provider_service` (a view) and the two
production marts (`mart_provider_summary`, `mart_procedure_summary`) as
tables in BigQuery. `dbt test` runs the not_null/unique checks defined in
the schema.yml files.

### 5. Connect Power BI to BigQuery

1. In Power BI Desktop: **Get Data → Google BigQuery**
2. Sign in with the same Google account that has access to your GCP project
3. Navigate to your project → `medicare_marts` dataset (or wherever dbt
   materialized the mart tables based on your `dbt_project.yml` schema config)
4. Select `mart_provider_summary` and `mart_procedure_summary`, build your
   visuals (top providers by payment, procedure cost by state map, etc.)

### 6. Publish for the live demo widget

**File → Publish → Publish to web** in Power BI Desktop (or from the
published report in the Power BI service). This generates an `<iframe>`
embed snippet — paste that directly into `projects.md` for a genuinely
live, filterable dashboard on your portfolio site. No backend service
needed for this one; Power BI hosts the interactivity itself.

**Note on "Publish to web":** this makes the report visible to anyone with
the link (which is what you want for a portfolio demo), and Microsoft adds
a small "made public" banner to embedded reports — expected behavior, not
a mistake in setup.

## Repo structure

```
medicare-data-pipeline/
├── dbt_project.yml
├── profiles.yml.example
└── models/
    ├── staging/
    │   ├── _staging__sources.yml
    │   ├── _staging__models.yml
    │   └── stg_medicare_provider_service.sql
    └── marts/
        ├── _marts__models.yml
        ├── mart_provider_summary.sql
        └── mart_procedure_summary.sql
```

## A note on column names

The staging model's column mapping (`Rndrng_NPI`, `Tot_Benes`, etc.)
follows CMS's naming convention as of the 2023+ dataset releases. CMS has
renamed columns between annual releases before — when you download the
actual file, open it and confirm the column headers match what's in
`stg_medicare_provider_service.sql` before running `dbt run`; adjust the
mapping if they've changed.
