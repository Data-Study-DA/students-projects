--create view goalscorers_overview
create view goalscorers_overview as 
with general as (
select *
,count() over (partition by date, home_team, away_team,team) as goals
,CASE 
    when home_team=team then 'home_team' else 'away_team'
END as goal_owner
from goalscorers g 
)
,prefinal as(
select 
distinct date
,home_team
,away_team
,goal_owner
,count(goal_owner) over (partition by date, home_team, away_team,goal_owner) as goal_count
from general)

select 
gen.date
,STRFTIME('%Y',gen.date) as year
,gen.home_team
,gen.away_team
,gen.team
,gen.scorer
,gen.minute
,gen.own_goal
,gen.penalty
,gen.goal_owner
,ifnull(pre.goal_count,0)  as 'home_goals'
,ifnull(pre2.goal_count,0) as 'away_goals'
from general gen
left join prefinal pre on pre.date=gen.date and pre.home_team=gen.home_team and pre.away_team=gen.away_team and pre.goal_owner='home_team'
left join prefinal pre2 on pre2.date=gen.date and pre2.home_team=gen.home_team and pre2.away_team=gen.away_team and pre2.goal_owner='away_team'
;

--create view playersdim
create view playersdim as 
with players as (
select 
distinct 
overw.year
,overw.team as country
,overw.scorer
,count(overw.date) over (partition by overw.year,scorer) as year_count_goals
,count(overw.date) over (partition by scorer) as count_goals
from goalscorers_overview overw
)
select *
,dense_rank() over (partition by year,country order by year_count_goals desc) as country_year_top_player
,dense_rank() over (partition by country order by count_goals desc) as country_top_player
,dense_rank() over (order by count_goals desc) as world_top_player
from players
;





--create view results_adj 
create view results_adj as
with prefinal as (
select 
date
,STRFTIME('%Y',date) as year
,home_team
,away_team
,home_score
,away_score
,tournament
,country
,CASE 
    when home_score > away_score then home_team
    when home_score < away_score then away_team
    else 'Draw' 
 END as 'winner'
from results r 
)

select
rj1.date
,rj1.year 
,rj1.home_team as team
,rj1.home_score as score
,rj1.tournament
,rj1.country
,rj1.home_score + rj1.away_score as ttl_score
,CASE 
    when rj1.winner=rj1.home_team then 'W'
    when rj1.winner = 'Draw' then 'D'
    else 'L'
END as winnerflag
,rj1.home_team ||' - ' || rj1.away_team as pair
from prefinal rj1
union 
select
rj2.date
,rj2.year 
,rj2.away_team as team
,rj2.away_score as score
,rj2.tournament
,rj2.country
,rj2.home_score + rj2.away_score as ttl_score
,CASE 
    when rj2.winner=rj2.away_team then 'W'
    when rj2.winner = 'Draw' then 'D'
    else 'L'
END as winnerflag
,rj2.away_team ||' - ' || rj2.home_team as pair
from prefinal rj2
