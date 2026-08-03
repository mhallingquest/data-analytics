
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select candidate_id
from `dataanalytics-504114`.`fec_dev_staging`.`stg_fec_candidates`
where candidate_id is null



  
  
      
    ) dbt_internal_test