-- COMP3311 12s1 Exam Q4
-- The Q4 view must have attributes called (team1,team2,matches)
drop view if exists MatchDetail;
create view MatchDetail
as
select 
  t1.country as team1,
  t2.country as team2,
  i1.match as matchid
from 
  involves i1
  join involves i2 on i1.match=i2.match
  join teams t1 on i1.team=t1.id
  join teams t2 on i2.team=t2.id
where t1.id < t2.id
;

create view NumMatches
as
select team1, team2, count(matchid) as matches
from MatchDetail
group by team1, team2
;

drop view if exists Q4;
create view Q4
as
select team1, team2, matches from NumMatches
where
  matches = (select max(matches) from NumMatches)
;

