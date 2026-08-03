

  create or replace view `dataanalytics-504114`.`superstore_dev_staging`.`stg_superstore_orders`
  OPTIONS()
  as -- Staging: light cleaning and renaming only. No business logic here.
--
-- This variant of the Superstore dataset is leaner than some other
-- "Superstore" uploads on Kaggle -- no order ID, product ID/name,
-- customer info, or dates. Just the fields below. BigQuery kept the
-- original headers' spaces/hyphens literally rather than converting them
-- to underscores, so they need backtick-quoting here.

with source as (

    select * from `dataanalytics-504114`.`superstore_raw`.`orders_raw`

),

renamed as (

    select
        `Ship Mode`                    as ship_mode,
        Segment                        as segment,
        Country                        as country,
        City                           as city,
        State                          as state,
        `Postal Code`                  as postal_code,
        Region                         as region,
        Category                       as category,
        `Sub-Category`                 as sub_category,
        cast(Sales as float64)         as sales,
        cast(Quantity as int64)        as quantity,
        cast(Discount as float64)      as discount,
        cast(Profit as float64)        as profit

    from source
    where Category is not null

)

select * from renamed;

