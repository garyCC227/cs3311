-- COMP3311 19T3 Assignment 2
-- Written by <<Linchen Chen, z5163479>>

--Global Helper: 
-- Movies View
create or replace view Movies
as
select * from titles where format = 'movie';

-- Q1 Which movies are more than 6 hours long? 

create or replace view Q1(title)
as
select main_title from Movies where runtime > 360;
;


-- Q2 What different formats are there in Titles, and how many of each?

create or replace view Q2(format, ntitles)
as
select format, count(*) from titles group by format;
;


-- Q3 What are the top 10 movies that received more than 1000 votes?

create or replace view Q3(title, rating, nvotes)
as
select main_title,rating, nvotes from Movies
where nvotes > 1000
order by 
	rating desc,
	main_title
limit 10
;


-- Q4 What are the top-rating TV series and how many episodes did each have?
--helper:
-- view for TV series
create or replace view TVSeries 
as
select * from titles
where format = 'tvSeries' or format = 'tvMiniSeries';

create or replace view Q4(title, nepisodes)
as
select t.main_title, count(e.episode) from tvseries t
join episodes e on t.id = e.parent_id
where
t.rating = (select max(rating) from tvseries)
group by t.main_title
order by t.main_title;
;


-- Q5 Which movie was released in the most languages?
-- title with its number of relases language view
create or replace view NLanguages(title_id, nlanguages)
as
select a.title_id, count(distinct a.language)
from aliases a
join movies m on m.id = a.title_id
where a.language is not null
group by a.title_id;

create or replace view Q5(title, nlanguages)
as
select m.main_title, n.nlanguages from movies m
join NLanguages n on n.title_id = m.id
where n.nlanguages = (select  max(nlanguages) from NLanguages) 
;


-- Q6 Which actor has the highest average rating in movies that they're known for?
-- view: actors
create or replace view Actors 
as
select * from worked_as 
where work_role = 'actor'
;
--view:name_id, number of movies involves, average rating
create or replace view ActorRating(name_id, num_movies, avg_rating)
as
select k.name_id, count(k.*), avg(m.rating) from known_for k
join movies m on m.id = k.title_id where m.rating is not null
group by k.name_id having count(k.*) >= 2
;
--help view: max avg rating name_id
create or replace view TopActors(name_id)
as
select name_id from Actorrating 
where avg_rating = (select max(avg_rating) from ActorRating
where name_id in (select name_id from Actors))
;

create or replace view Q6(name)
as
select name from names
where id in (select * from topactors);
;

-- Q7 For each movie with more than 3 genres, show the movie title and a comma-separated list of the genres
-- view, title that have more than 3 genres
create or replace view Title3Genres(title_id, genres)
as
select title_id
, string_agg(genre,',' order by genre)
from title_genres group by title_id having count(*) > 3
;

create or replace view Q7(title,genres)
as
select m.main_title, t.genres from 
Title3Genres t
join movies m on m.id = t.title_id;
;

-- Q8 Get the names of all people who had both actor and crew roles on the same movie
-- view:both role in titles;
create or replace view BothRole(name, title_id)
as
select distinct n.name,a.title_id from names n
join actor_roles a on a.name_id = n.id
join crew_roles c on a.title_id = c.title_id and n.id=c.name_id
;

create or replace view Q8(name)
as
select distinct name from bothrole b
join movies m on m.id = b.title_id
;

-- Q9 Who was the youngest person to have an acting role in a movie, and how old were they when the movie started?
-- view for actor with theri id and acting age
create or replace view ActingAge
as
select a.name_id, min(m.start_year - n.birth_year) as age
from actor_roles a
join movies m on m.id=a.title_id
join names n on a.name_id = n.id
group by a.name_id
;

create or replace view Q9(name,age)
as
select n.name,a.age from names n 
join actingage a on a.name_id = n.id
where a.age = (select min(age) from actingage)
;

-- Q10 Write a PLpgSQL function that, given part of a title, shows the full title and the total size of the cast and crew

create type MyTitle as (id integer, main_title text);

create or replace function
	Q10(partial_title text) returns setof text
as $$
declare
	title MyTitle;
	_count integer;
begin
	-- find all the title that match the 'partial_title'
	-- then loop through each title -> to find the total size of crew and cast
	for title in (
		select t.id,t.main_title from titles t 
		join principals a on t.id = a.title_id
		where t.main_title ilike ('%'|| partial_title ||'%')
		union                                 
		select t.id,t.main_title from titles t  
		join actor_roles a on t.id = a.title_id
		where t.main_title ilike ('%'|| partial_title ||'%')
		union
		select t.id,t.main_title from titles t
		join crew_roles c on t.id = c.title_id
		where t.main_title ilike ('%'|| partial_title ||'%'))
	loop
		select count(*) into _count
		from 
			(select name_id from actor_roles 
			where title_id = title.id
			union
			select name_id from principals
			where title_id = title.id
			union
			select name_id from crew_roles 
			where title_id = title.id
			) as foo;
    return next format('%s has %s cast and crew', title.main_title, _count);
	end loop;
  if title is null then
    return next format('No matching titles');
  end if;
end;
$$ language plpgsql;
