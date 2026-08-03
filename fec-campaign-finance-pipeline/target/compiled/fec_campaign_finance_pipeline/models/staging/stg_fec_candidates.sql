-- Staging: light cleaning and renaming only. No business logic here.
--
-- Source: FEC's official candidate_summary_2026.csv bulk file, downloaded
-- directly from fec.gov/data/browse-data/?tab=bulk-data (2025-2026 cycle).
-- Column names below match BigQuery's autodetect exactly, verified against
-- the real downloaded file's header row before writing this model — these
-- headers already use underscores (Cand_Name, Total_Receipt, etc.), so no
-- backtick-quoting needed, unlike the Superstore project's spaced headers.
--
-- NOTE: many candidates legitimately show $0 across every financial field —
-- this isn't stripped/missing data (unlike the GA4 project), it's simply
-- true: most declared candidates, especially early in a cycle or in
-- uncompetitive races, haven't raised or spent anything yet.

with source as (

    select * from `dataanalytics-504114`.`fec_raw`.`candidate_summary_raw`

),

renamed as (

    select
        Cand_Id                                    as candidate_id,
        Cand_Name                                   as candidate_name,
        Cand_Office                                 as office,               -- H = House, S = Senate, P = President
        Cand_Office_St                              as office_state,
        Cand_Office_Dist                            as office_district,
        Cand_Party_Affiliation                      as party_affiliation,
        Cand_Incumbent_Challenger_Open_Seat          as incumbent_status,
        cast(Total_Receipt as float64)               as total_receipts,
        cast(Total_Disbursement as float64)          as total_disbursements,
        cast(Cash_On_Hand_COP as float64)            as cash_on_hand,
        cast(Debt_Owed_By_Committee as float64)      as debt_owed,
        cast(Individual_Contribution as float64)     as individual_contributions,
        cast(Cand_Contribution as float64)           as candidate_self_funding,
        cast(Cand_Loan as float64)                   as candidate_loans,
        cast(Total_Contribution as float64)          as total_contributions,
        Coverage_Start_Date                         as coverage_start_date,
        Coverage_End_Date                           as coverage_end_date

    from source
    where Cand_Id is not null

)

select * from renamed