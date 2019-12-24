-- COMP3311 12s1 Exam Q6
-- The Q6 view must have attributes called
-- (location,date,team1,goals1,team2,goals2)

drop view if exists ScoresInMatch;
create view ScoresInMatch
as
select f.match, f.team, t.country, f.goals from
(select g.scoredin as match, p.memberof as team, count(*) as goals from goals g
join players p on g.scoredby = p.id
group by g.scoredin, p.memberof
) as f
join teams t on t.id = f.team
;

drop view if exists MatchDetails;
create view MatchDetails
as
select m.city as location, m.playedon as date, i1.match as matchid, 
  t1.country as team1, t2.country as team2
from involves i1 
  join involves i2 on i1.match = i2.match
  join teams t1 on i1.team = t1.id
  join teams t2 on i2.team = t2.id
  join matches m on m.id = i1.match
where t1.country < t2.country
;

drop view if exists team1Score;
create view team1Score
as
select 
  m.location, m.date, m.matchid, m.team1, ifnull(s.goals,0) as goals1, m.team2 
from MatchDetails m
left join ScoresInMatch s 
  on m.matchid = s.match and m.team1 = s.country
;

drop view if exists Q6;
create view Q6
as
select 
  m.location, m.date, m.team1, m.goals1, m.team2 , ifnull(s.goals,0) as goals2
from team1Score m
left join ScoresInMatch s 
  on m.matchid = s.match and m.team2 = s.country
;

