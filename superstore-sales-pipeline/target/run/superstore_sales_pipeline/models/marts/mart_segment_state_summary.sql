
  
    

    create or replace table `dataanalytics-504114`.`superstore_dev_marts`.`mart_segment_state_summary`
      
    
    

    
    OPTIONS()
    as (
      -- Production mart: sales and profit by customer segment and state.
-- Replaces the originally-planned product-level mart, which isn't
-- buildable with this dataset variant (no product ID/name present).
-- Segment + state is a genuinely useful cut this data DOES support well
-- -- e.g. "is the Consumer segment profitable in every state, or are
-- there specific regions dragging down an otherwise-healthy segment?"

with orders as (

    select * from `dataanalytics-504114`.`superstore_dev_staging`.`stg_superstore_orders`

),

segment_state_summary as (

    select
        segment,
        state,
        region,
        count(*)                             as line_item_count,
        sum(sales)                           as total_sales,
        sum(profit)                          as total_profit,
        sum(quantity)                        as total_quantity,
        avg(discount)                        as avg_discount,
        safe_divide(sum(profit), sum(sales)) as profit_margin

    from orders
    group by
        segment,
        state,
        region

)

select * from segment_state_summary
    );
  