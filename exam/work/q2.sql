-- COMP3311 12s1 Exam Q2
-- The Q2 view must have one attribute called (player,goals)

drop view if exists Q2;
create view Q2
as
select p.name as player, foo.goals 
from (select scoredby as player, count(scoredby) as goals from goals 
where rating = 'amazing'
group by scoredby
having count(scoredby) > 1
) as foo
join players p on p.id = foo.player
;

