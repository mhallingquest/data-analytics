
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select procedure_code
from `dataanalytics-504114`.`medicare_dev_marts`.`mart_procedure_summary`
where procedure_code is null



  
  
      
    ) dbt_internal_test