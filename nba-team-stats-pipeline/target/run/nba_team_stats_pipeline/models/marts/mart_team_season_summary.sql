
  
    

    create or replace table `dataanalytics-504114`.`nba_dev_marts`.`mart_team_season_summary`
      
    
    

    
    OPTIONS()
    as (
      -- Production mart: one row per team per season. Powers the team
-- performance views — wins/losses, scoring, shooting efficiency, and
-- point differential across a full season.

with games as (

    select * from `dataanalytics-504114`.`nba_dev_staging`.`stg_nba_team_game_totals`

),

team_season_summary as (

    select
        season_year,
        team_id,
        team_abbreviation,
        any_value(team_name)                     as team_name,
        count(distinct game_id)                  as games_played,
        countif(win_loss = 'W')                  as wins,
        countif(win_loss = 'L')                  as losses,
        safe_divide(countif(win_loss = 'W'), count(distinct game_id)) as win_pct,
        avg(points)                              as avg_points_per_game,
        avg(point_differential)                  as avg_point_differential,
        avg(field_goal_pct)                      as avg_field_goal_pct,
        avg(three_point_pct)                     as avg_three_point_pct,
        avg(free_throw_pct)                      as avg_free_throw_pct,
        avg(total_rebounds)                      as avg_rebounds_per_game,
        avg(assists)                             as avg_assists_per_game,
        avg(turnovers)                           as avg_turnovers_per_game

    from games
    group by
        season_year,
        team_id,
        team_abbreviation

)

select * from team_season_summary
    );
  