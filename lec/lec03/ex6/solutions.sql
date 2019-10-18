
-- Q1 What beers are made by Toohey's?

-- "made by" = Beers.manf
-- the only trick here is the quote

select name from Beers where manf = 'Toohey''s';


-- Q2 Show beers with headings "Beer", "Brewer"

-- use "as" to change the column names
-- need double quotes to ensure first char is upper-case

select name as "Beer", manf as "Brewer" from beers;


-- Q3 How many different beers are there?

-- "different beers" means "distinct beers"
-- Since name is a primary key, no chance of duplicates

select count(name) from beers;

-- So this should give the same result as above

select count(distinct name) from beers;

-- Soln:

select count(name) from beers;


-- Q4 How many different brewers are there?

-- Since brewers may appear in several Beers tuples,
-- the two queries below have different results

select count(manf) from beers;
select count(distinct manf) from beers;

-- we're asked for "different brewers" = "distinct brewers"

-- Soln:

select count(distinct manf) from beers;


-- Q5a. Which beers does John like?

-- the Likes table contains bother drinker and beer names

-- Soln:

select beer from Likes where drinker = 'John';

-- Q5b.  Find the brewers whose beers John likes.

-- two approaches:
-- * use the previous query to get a set of beers
-- * join Likes with Beers and filter
-- since may like >1 from same brewer, need distinct

-- Soln1:

select distinct manf as brewer
from   Beers
where  name in (select beer from Likes where drinker = 'John');

-- Soln2:

select distinct b.manf
from   Beers b join Likes k on b.name = k.beer
where  k.drinker = 'John';

-- note: JOIN is generally preferred over nested queries


-- Q6.  Find pairs of beers by the same manufacturer.

-- to get pairs of beers, need to join Beers with itself
-- need to name tables to distinguish which table each name comes from

select b1.name, b2.name
from   Beers b1 join Beers b2 on (b1.manf = b2.manf);

-- but this query results in (A,A) and (A,B) and (B,A)
-- to fix this ... and keeping only (A,B) ...
-- Soln:

select b1.name, b2.name
from   Beers b1 join Beers b2 on (b1.manf = b2.manf)
where  b1.name < b2.name;

-- if you're interested in also knowing who the brewer is
select b1.name, b2.name, b1.manf
from   Beers b1 join Beers b2 on (b1.manf = b2.manf)
where  b1.name < b2.name;


-- Q7a How many beers does each brewer make?

-- makes the subsequent easy if we do this as a view

create or replace view nb(brewer, nbeers)
as
select manf, count(name)
from   Beers
group  by manf;

select * from nb;

-- Q7b Which brewers make only one beer?

-- easy with the view

select brewer from nb where nbeers = 1;

-- Q7c Find beers that are the only one by their brewer

-- Soln: Select beers whose brewer is one of those who makes only one beer

-- as a subquery
select name
from   Beers
where  manf in (select brewer from nb where nbeers = 1);

--- using a join
select b.name
from   beers b join nb on (b.manf = nb.brewer)
where  nb.nbeers = 1;


-- Q8 Find the beers sold at the bars where John drinks

-- AA: set of bars where John drinks

select bar from frequents where drinker='John';

-- Soln: Which beers are sold in a bar belonging to the set AA

select beer
from   Sells
where  bar in (select bar from frequents where drinker='John');

-- Alternative

-- Collect together info about beers sold in bars and drinkers who drink in them

select s.beer, s.bar, f.drinker
from   Sells s join Frequents f on (f.bar = s.bar);

-- Filter entries that are for John (has duplicates)

select s.beer
from   Sells s join Frequents f on (f.bar = s.bar)
where  f.drinker = 'John';

-- Soln: eliminate duplicates

select distinct s.beer
from   Sells s join Frequents f on (f.bar = s.bar)
where  f.drinker = 'John';


-- Q9 How many beers does each brewer make

-- we've already seen the basic query for this

select manf,count(name)
from   Beers
group by manf;

-- since it seems useful, let's turn it into a view

create view BrewersBeers(brewer,nbeers) as
select manf,count(name)
from   Beers
group by manf;

-- Soln:

select * from BrewersBeers;


-- Q10 Which brewer makes the most beers?

-- most number of beers by one brewer

select max(nbeers) from brewersbeers ;

-- Soln: get the brewer who makes this many beers

select brewer
from   BrewersBeers 
where  nbeers = (select max(nbeers) from BrewersBeers);


-- Q11 Bars where either Gernot or John drink

-- information for this query is in the Frequents table

select * from frequents;

-- we want tuples which have a drinker which is either Gernot or John

select bar from frequents where drinker='Gernot' or drinker='John';

-- or

select distinct bar from frequents where drinker in ('Gernot','John');


-- Q12 Bars where both John and Gernot drink

-- same approach as above doesn't work ...
-- in a given tuple, the drinker cannot have two values

-- WRONG:
select bar from frequents where drinker='Gernot' and drinker='John';

-- could use set intersection
-- (set of Gernot's bars) and (set of John's bars)

-- Soln:

(select bar from frequents where drinker='Gernot')
intersect
(select bar from frequents where drinker='John');

-- Alternative: generate pairs of dinkers with a common bar

select d1.bar, d1.drinker, d2.drinker
from Frequents d1 join Frequents d2 on (d1.bar = d2.bar);

-- will generate (B,D1,D2) and (B,D2,D1) for all pairs
-- so we can take just one ordering and not miss anything

-- Soln:

select d1.bar, d1.drinker, d2.drinker
from Frequents d1 join Frequents d2 on (d1.bar = d2.bar)
where d1.drinker = 'Gernot' and d2.drinker = 'John';


-- Q11 reprised ... the set approach also works for OR

-- Soln: (set of Gernot's bars) union (set of John's bars)

(select bar from frequents where drinker='Gernot')
union
(select bar from frequents where drinker='John');

-- set operations remove duplicates
-- if we really want them, use "union all"

(select bar from frequents where drinker='Gernot')
union all
(select bar from frequents where drinker='John');


-- Q12 Find bars that serve New at the same price
--     as the Coogee Bay Hotel (CBH) charges for VB.

-- Step 1: find the price that CBH charges for VB

create or replace view CBH_VB_price
as
select price
from   Sells
where  bar = 'Coogee Bay Hotel' and beer = 'Victoria Bitter';

-- Since this a single value (primary key) we can use it
-- like a double precision constant in a query

-- Soln:
select bar
from   Sells
where  price = (select price from CBH_VB_price)
       and bar <> 'Coogee Bay Hotel';

create view CommonBeers
select 

-- Q13 Find the average price of common beers
--     (i.e. those that are served in more than two hotels).

-- useful first step, make a "table" (view) of common beers
-- requires us to form groups of beers from Sells table
-- and then filter jusy this groups HAVIING more that two entries

create or replace view CommonBeers
as
select beer
from   Sells
group  by beer
having count(bar) > 2;

-- then use avg() to determine the average price
-- assuming we mean average price per beer, group by beers
-- can collect prices either via a JOIN or using a nested query

-- Soln:
select beer, avg(price)
from   Sells
where  beer in (select * from CommonBeers)
group  by beer;

-- to make the number values look nicer
select beer, avg(price)::numeric(5,2) as "AvgPrice"
from   Sells
where  beer in (select * from CommonBeers)
group  by beer;


-- Q14 Which bar sells 'New' cheapest?

-- find the cheapest price at which New is sold

select min(price) from Sells where beer='New';

-- then find the Sells record that has this price
-- Soln:

select bar
from   Sells
where  beer = 'New'
       and price = (select min(price) from Sells where beer='New');

-- following is not a valid solution to this problem

select bar from Sells where beer = 'New' order by price limit 1;

-- it works for this database instance because only one bar sells
-- New at the cheapest price; it would omit some correct results
-- if more than one Bar sold New at its cheapest price
