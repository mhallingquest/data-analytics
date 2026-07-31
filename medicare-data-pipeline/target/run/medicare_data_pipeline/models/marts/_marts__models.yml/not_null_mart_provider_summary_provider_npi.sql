
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select provider_npi
from `dataanalytics-504114`.`medicare_dev_marts`.`mart_provider_summary`
where provider_npi is null



  
  
      
    ) dbt_internal_test