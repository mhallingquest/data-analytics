-- Production mart: total fundraising aggregated by party affiliation and
-- office type (House/Senate/President). Powers the "which parties/races
-- are attracting the most money" view — the headline story for a 2026
-- midterm-cycle dashboard.

with candidates as (

    select * from `dataanalytics-504114`.`fec_dev_staging`.`stg_fec_candidates`

),

party_office_summary as (

    select
        office,
        party_affiliation,
        count(distinct candidate_id)              as candidate_count,
        sum(total_receipts)                       as total_raised,
        sum(total_disbursements)                  as total_spent,
        sum(cash_on_hand)                         as total_cash_on_hand,
        sum(individual_contributions)             as total_individual_contributions,
        sum(candidate_self_funding)               as total_self_funding,
        avg(total_receipts)                       as avg_raised_per_candidate

    from candidates
    group by
        office,
        party_affiliation

)

select * from party_office_summary