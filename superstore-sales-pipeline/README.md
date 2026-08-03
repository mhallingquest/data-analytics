# Superstore Sales Pipeline

A complete, working data pipeline built on the Sample Superstore dataset —
raw CSV → BigQuery → dbt (staging + production marts) → Power BI dashboard.
Chosen specifically because every field is populated by design (no
stripped/missing data like the GA4 attempt ran into) — this dataset is
built for practicing exactly this kind of analysis.

## Data source

**Sample Superstore Dataset** on Kaggle:
https://www.kaggle.com/datasets/bravehart101/sample-supermarket-dataset
(or any of the several equivalent "Superstore" uploads on Kaggle — they're
all the same underlying dataset). ~10,000 rows, ~180KB, no account needed
beyond a free Kaggle login to download.

Columns: Row ID, Order ID, Order Date, Ship Date, Ship Mode, Customer ID,
Customer Name, Segment, Country, City, State, Postal Code, Region,
Product ID, Category, Sub-Category, Product Name, Sales, Quantity,
Discount, Profit.

## Pipeline architecture

```
Kaggle CSV (download)
    → BigQuery (direct upload -- small enough to skip Cloud Storage entirely)
    → dbt staging model (clean/rename/type-cast)
    → dbt mart models (category/region summary, product performance)
    → Power BI (connects to BigQuery marts)
```

## Setup

### 1. Download the CSV
From the Kaggle link above (or any equivalent "Sample Superstore" dataset).

### 2. Upload directly into BigQuery (no Cloud Storage needed this time)

1. In BigQuery, create a dataset: three-dot menu next to your project →
   **Create dataset** → name it `superstore_raw`
2. Three-dot menu next to `superstore_raw` → **Create table**
3. Source: **Upload** → browse to the CSV
4. Table name: `orders_raw`
5. Schema: check **Auto detect**
6. Create Table

At ~180KB, this uploads in seconds — no size limit concerns at all this time.

### 3. Check the actual column names BigQuery detected

Click into `orders_raw` → **Schema** tab. Compare against the mapping in
`models/staging/stg_superstore_orders.sql` — BigQuery's autodetect usually
converts spaces/hyphens to underscores (e.g. "Sub-Category" → `Sub_Category`),
but confirm before running dbt, and adjust the staging model if anything
differs.

**Also check whether `Order_Date`/`Ship_Date` got typed as DATE or STRING**
(visible in the Schema tab) — the staging model assumes DATE (a direct
passthrough); if BigQuery left them as STRING instead, swap in the
commented `parse_date()` alternative in the staging model.

### 4. Set up dbt

Add the profile from `profiles.yml.example` into your existing
`~/.dbt/profiles.yml` (alongside your Medicare and GA4 profiles), filling
in your real project ID and keyfile path.

Update `models/staging/_staging__sources.yml`'s `database:` to your real
project ID too.

### 5. Run it

```bash
dbt run
dbt test
```

### 6. Connect Power BI

Same as before: Get Data → Google BigQuery → sign in → Navigator → select
`mart_category_region_summary` and `mart_product_performance` → Load
(Import mode).

## Dashboard ideas this data supports well

- **Profit margin by category/region** — which categories/regions are
  actually profitable vs. just high-volume
- **Discount impact on profit** — scatter or combo chart showing
  avg_discount vs. profit_margin; the classic "heavy discounting kills
  margin" story this dataset is well-suited to tell
- **Top/bottom products by profit** — not just top sellers, but which
  products are quietly losing money (a Top N filter on total_profit
  ascending, rather than descending, surfaces these)
