
  
    

    create or replace table `dataanalytics-504114`.`superstore_dev_marts`.`mart_category_region_summary`
      
    
    

    
    OPTIONS()
    as (
      -- Production mart: sales and profit aggregated by category, sub-category,
-- and region. Powers the profitability-by-category/region views in Power
-- BI, including the discount-vs-profit story (heavy discounting often
-- looks good for sales volume while quietly destroying margin).
--
-- NOTE: this dataset has no order ID, so "line_item_count" (a row count)
-- stands in for order volume rather than a true distinct-order count.

with orders as (

    select * from `dataanalytics-504114`.`superstore_dev_staging`.`stg_superstore_orders`

),

category_region_summary as (

    select
        category,
        sub_category,
        region,
        count(*)                          as line_item_count,
        sum(sales)                        as total_sales,
        sum(profit)                       as total_profit,
        sum(quantity)                     as total_quantity,
        avg(discount)                     as avg_discount,
        safe_divide(sum(profit), sum(sales)) as profit_margin

    from orders
    group by
        category,
        sub_category,
        region

)

select * from category_region_summary
    );
  