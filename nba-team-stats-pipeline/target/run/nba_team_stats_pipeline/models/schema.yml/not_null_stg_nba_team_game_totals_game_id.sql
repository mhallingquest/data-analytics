
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select game_id
from `dataanalytics-504114`.`nba_dev_staging`.`stg_nba_team_game_totals`
where game_id is null



  
  
      
    ) dbt_internal_test