-- COMP3311 12s1 Exam Q5
-- The Q5 view must have attributes called (team,reds,yellows)

drop view if exists TeamReds;
create view TeamReds
as
select 
  t.country as team,
  count(*) as reds
from
  teams t
  left join cards c on p.id = c.givenTo
  join players p on t.id = p.memberof
where c.cardType = 'red'
group by t.id
;

drop view if exists TeamYellows;
create view TeamYellows
as
select 
  t.country as team,
  count(*) as yellows
from
  cards c 
  join players p on p.id = c.givenTo
  join teams t on t.id = p.memberof
where cardType = 'yellow'
group by t.id
;



drop view if exists Q5;
create view Q5
as
select t.country as team, ifnull(r.reds,0) as reds, ifnull(y.yellows,0) as yellows  from teams t
left join TeamReds r on t.country = r.team
left join TeamYellows y on t.country = y.team
;
