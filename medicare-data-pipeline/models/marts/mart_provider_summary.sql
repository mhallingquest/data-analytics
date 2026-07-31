-- Production mart: one row per provider, aggregated across all their
-- billed services. This is what Power BI connects to for provider-level
-- views (top billers, specialty breakdowns, geographic distribution).

with staged as (

    select * from {{ ref('stg_medicare_provider_service') }}

),

provider_summary as (

    select
        provider_npi,
        provider_last_or_org_name,
        provider_first_name,
        provider_specialty,
        provider_state,
        provider_city,
        count(distinct procedure_code)        as distinct_procedures_billed,
        sum(total_services)                   as total_services_rendered,
        sum(total_beneficiaries)               as total_beneficiaries_served,
        sum(total_services * avg_medicare_payment_amount) as total_medicare_paid,
        avg(avg_medicare_payment_amount)       as avg_payment_per_service

    from staged
    group by
        provider_npi,
        provider_last_or_org_name,
        provider_first_name,
        provider_specialty,
        provider_state,
        provider_city

)

select * from provider_summary
