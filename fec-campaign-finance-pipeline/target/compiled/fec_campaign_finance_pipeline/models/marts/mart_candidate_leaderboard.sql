-- Production mart: one row per candidate, with state/office/party context.
-- Powers the "top fundraisers" leaderboard view and state-level maps.
--
-- Grain is candidate_id (the reliable FEC-assigned identifier) — not a
-- composite of candidate_id + name + state, applying the same defensive
-- grouping lesson from the GA4/Superstore projects: group by the one field
-- you can trust, use ANY_VALUE() for descriptive context.

with candidates as (

    select * from `dataanalytics-504114`.`fec_dev_staging`.`stg_fec_candidates`

),

candidate_leaderboard as (

    select
        candidate_id,
        any_value(candidate_name)          as candidate_name,
        any_value(office)                  as office,
        any_value(office_state)            as office_state,
        any_value(office_district)         as office_district,
        any_value(party_affiliation)       as party_affiliation,
        any_value(incumbent_status)        as incumbent_status,
        sum(total_receipts)                as total_receipts,
        sum(total_disbursements)           as total_disbursements,
        sum(cash_on_hand)                  as cash_on_hand,
        sum(debt_owed)                     as debt_owed,
        sum(candidate_self_funding)        as candidate_self_funding

    from candidates
    group by
        candidate_id

)

select * from candidate_leaderboard