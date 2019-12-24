-- 1.
-- drop view if exists q1;
-- create view q1
-- as
-- select p.id, p.name, count(*) from people p
-- left join likes l on p.id = l.person
-- group by p.id, p.name;


--2. store sold 0 pizza?
select s.id,count(*) as sold_how_many, sum(si.price) as total_price, 
sum(si.price - r.base_price) as profit ,
sum( sb.surcharge) as profit_no_surchage
from stores s
join soldIn si on s.id = si.store
join pizzas p on p.id = si.pizza
join ranges r on p.part_of = r.id
join suburbs sb on sb.id = s.located_in
group by s.id
;

--- favour pizza
-- drop view if exists Fav;
-- create view Fav
-- as
-- select * from likes l
-- join people p on l.person = p.id
-- where l.how_much = 'Favourite'
-- ;

-- select p.name, pi.name, f.how_much 
-- from people p 
-- left join Fav f on f.person = p.id
-- left join pizzas pi on f.pizza = pi.id
-- ;




---- pizza with topping 
-- select p.id, p.name,r.name, count(*) from pizzas p
-- join has h on h.pizza = p.id
-- join toppings t on t.id = h.topping
-- join ranges r on p.part_of = r.id
-- group by p.id, p.name, r.name
-- ;