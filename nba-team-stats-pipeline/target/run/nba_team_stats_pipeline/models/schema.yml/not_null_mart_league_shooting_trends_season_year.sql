
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select season_year
from `dataanalytics-504114`.`nba_dev_marts`.`mart_league_shooting_trends`
where season_year is null



  
  
      
    ) dbt_internal_test