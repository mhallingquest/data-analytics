-- Production mart: league-wide averages by season (across all teams and
-- games). Powers the "3-point revolution" story — this era (2010-2024)
-- captures one of the most dramatic tactical shifts in NBA history, as
-- 3-point attempt volume rose sharply while long-2 attempts declined.

with games as (

    select * from `dataanalytics-504114`.`nba_dev_staging`.`stg_nba_team_game_totals`

),

league_trends as (

    select
        season_year,
        count(distinct game_id)                   as total_games,
        avg(points)                                as avg_points_per_team_game,
        avg(three_pointers_attempted)              as avg_three_pt_attempts,
        avg(three_pointers_made)                   as avg_three_pt_made,
        avg(three_point_pct)                       as avg_three_pt_pct,
        avg(field_goals_attempted)                 as avg_field_goal_attempts,
        avg(field_goal_pct)                        as avg_field_goal_pct,
        avg(total_rebounds)                        as avg_rebounds,
        avg(assists)                                as avg_assists

    from games
    group by
        season_year

)

select * from league_trends