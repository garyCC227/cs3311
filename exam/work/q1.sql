-- COMP3311 12s1 Exam Q1
-- The Q1 view must have attributes called (team,matches)

drop view if exists q1;
create view Q1
as
select t.country as team, count(i.match)
from teams t 
join involves i on i.team = t.id
group by i.match;
























-- drop view if exists Q1;
-- create view Q1
-- as
-- select t.country as team, count(i.match) as matches
-- from   Teams t join Involves i on t.id = i.team
-- group  by t.country
-- ;

