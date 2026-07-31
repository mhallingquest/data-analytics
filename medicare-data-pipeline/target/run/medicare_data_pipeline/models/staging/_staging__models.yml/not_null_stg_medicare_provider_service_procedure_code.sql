
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select procedure_code
from `dataanalytics-504114`.`medicare_dev_staging`.`stg_medicare_provider_service`
where procedure_code is null



  
  
      
    ) dbt_internal_test