
    
    

with dbt_test__target as (

  select season_year as unique_field
  from `dataanalytics-504114`.`nba_dev_marts`.`mart_league_shooting_trends`
  where season_year is not null

)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1


