
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select provider_npi
from `dataanalytics-504114`.`medicare_dev_staging`.`stg_medicare_provider_service`
where provider_npi is null



  
  
      
    ) dbt_internal_test