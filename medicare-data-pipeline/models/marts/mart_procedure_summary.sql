-- Production mart: one row per (procedure code, state), aggregated across
-- all providers. This is what Power BI connects to for "which procedures
-- cost the most, and where" style views — the map/geography visuals.

with staged as (

    select * from {{ ref('stg_medicare_provider_service') }}

),

procedure_summary as (

    select
        procedure_code,
        procedure_description,
        provider_state,
        count(distinct provider_npi)          as distinct_providers_billing,
        sum(total_services)                   as total_services_rendered,
        sum(total_beneficiaries)               as total_beneficiaries_served,
        avg(avg_submitted_charge)              as avg_submitted_charge,
        avg(avg_medicare_allowed_amount)       as avg_medicare_allowed_amount,
        avg(avg_medicare_payment_amount)       as avg_medicare_payment_amount,
        sum(total_services * avg_medicare_payment_amount) as total_medicare_paid

    from staged
    group by
        procedure_code,
        procedure_description,
        provider_state

)

select * from procedure_summary
