-- COMP3311 12s1 Exam Q3
-- The Q3 view must have attributes called (team,players)

drop view if exists ZeroG;
create view ZeroG
as
select * from players
where id not in 
(select scoredby from goals
group by scoredby)
;

-- select team, max(player) from 
-- (select t.country as team, count(z.memberof) as player
-- from zeroG z
-- join teams t on t.id = z.memberof
-- group by memberof
-- ) as foo
-- ;
drop view if exists TeamDetail;
create view TeamDetail
as
select t.country as team, count(z.memberof) as player
from zeroG z
join teams t on t.id = z.memberof
group by memberof
;


drop view if exists Q3;
create view Q3
as
select team, player from TeamDetail
where
 player = (select max(player) as players from TeamDetail)
;
