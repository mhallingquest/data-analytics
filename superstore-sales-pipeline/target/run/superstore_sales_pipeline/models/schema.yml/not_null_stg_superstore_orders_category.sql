
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select category
from `dataanalytics-504114`.`superstore_dev_staging`.`stg_superstore_orders`
where category is null



  
  
      
    ) dbt_internal_test