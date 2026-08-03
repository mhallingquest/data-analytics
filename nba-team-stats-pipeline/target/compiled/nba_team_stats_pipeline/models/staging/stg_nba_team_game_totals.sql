-- Staging: light cleaning and renaming only. No business logic here.
--
-- Source: NocturneBear/NBA-Data-2010-2024 GitHub repo, "regular season
-- totals" file. Column names below match the repo's own documented README
-- schema exactly, verified against the source before writing this model —
-- one row per team per game (each game produces two rows).
--
-- Note: PLUS_MINUS is the team's point differential for that specific
-- game — using this directly avoids needing a self-join against the
-- opponent's row to calculate scoring margin.

with source as (

    select * from `dataanalytics-504114`.`nba_raw`.`team_game_totals_raw`

),

renamed as (

    select
        cast(SEASON_YEAR as string)        as season_year,
        TEAM_ID                            as team_id,
        TEAM_ABBREVIATION                  as team_abbreviation,
        TEAM_NAME                          as team_name,
        GAME_ID                            as game_id,
        GAME_DATE                          as game_date,
        MATCHUP                            as matchup,
        WL                                 as win_loss,
        cast(FGM as int64)                 as field_goals_made,
        cast(FGA as int64)                 as field_goals_attempted,
        cast(FG_PCT as float64)            as field_goal_pct,
        cast(FG3M as int64)                as three_pointers_made,
        cast(FG3A as int64)                as three_pointers_attempted,
        cast(FG3_PCT as float64)           as three_point_pct,
        cast(FTM as int64)                 as free_throws_made,
        cast(FTA as int64)                 as free_throws_attempted,
        cast(FT_PCT as float64)            as free_throw_pct,
        cast(OREB as int64)                as offensive_rebounds,
        cast(DREB as int64)                as defensive_rebounds,
        cast(REB as int64)                 as total_rebounds,
        cast(AST as int64)                 as assists,
        cast(TOV as int64)                 as turnovers,
        cast(STL as int64)                 as steals,
        cast(BLK as int64)                 as blocks,
        cast(PF as int64)                  as personal_fouls,
        cast(PTS as int64)                 as points,
        cast(PLUS_MINUS as float64)        as point_differential

    from source
    where GAME_ID is not null

)

select * from renamed