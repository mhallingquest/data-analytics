-- Staging: light cleaning and renaming only. No business logic here —
-- staging models exist to normalize types/names so every downstream model
-- works from a consistent, well-typed source.
--
-- Source: raw BigQuery table loaded from the CMS "Medicare Physician &
-- Other Practitioners - by Provider and Service" CSV. Column names below
-- follow CMS's Rndrng_*/Tot_*/Avg_* naming convention as of the 2023+
-- release — verify against the actual data dictionary in your downloaded
-- file, since CMS occasionally renames columns between annual releases.

with source as (

    select * from {{ source('medicare_raw', 'provider_service_raw') }}

),

renamed as (

    select
        Rndrng_NPI                      as provider_npi,
        Rndrng_Prvdr_Last_Org_Name      as provider_last_or_org_name,
        Rndrng_Prvdr_First_Name         as provider_first_name,
        Rndrng_Prvdr_Type               as provider_specialty,
        Rndrng_Prvdr_State_Abrvtn       as provider_state,
        Rndrng_Prvdr_City               as provider_city,
        HCPCS_Cd                        as procedure_code,
        HCPCS_Desc                      as procedure_description,
        Place_Of_Srvc                   as place_of_service,
        cast(Tot_Benes as int64)        as total_beneficiaries,
        cast(Tot_Srvcs as int64)        as total_services,
        cast(Avg_Sbmtd_Chrg as float64) as avg_submitted_charge,
        cast(Avg_Mdcr_Alowd_Amt as float64) as avg_medicare_allowed_amount,
        cast(Avg_Mdcr_Pymt_Amt as float64)  as avg_medicare_payment_amount

    from source
    where Rndrng_NPI is not null

)

select * from renamed
