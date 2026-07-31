
    
    

with dbt_test__target as (

  select provider_npi as unique_field
  from `dataanalytics-504114`.`medicare_dev_marts`.`mart_provider_summary`
  where provider_npi is not null

)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1


