
    
    

with dbt_test__target as (

  select candidate_id as unique_field
  from `dataanalytics-504114`.`fec_dev_marts`.`mart_candidate_leaderboard`
  where candidate_id is not null

)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1


