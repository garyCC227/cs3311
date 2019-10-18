create or replace function
	Q10(partial_title text) returns setof text
as $$
declare
	title MyTitle;
	_count integer;
begin
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