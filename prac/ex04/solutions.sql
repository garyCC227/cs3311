-- -- 1.
-- select count(*) from accesses 
-- where acctime::text ~ '2005-03-02.*';


-- 2.
-- select count(*) from accesses where
-- page ~* 'webgms/messageboard/index'
-- and params ~* '.*state=search.*';


--3.
-- TODO: wrong answer?
-- select distinct h.id, h.hostname from Hosts h 
-- join sessions s on s.id = h.id
-- where h.hostname ~* '^tuba.*' and s.complete=false


--4. 
-- select min(nbytes), avg(nbytes)::integer, max(nbytes) 
-- from accesses;

--5.
-- TODO: ?
create or replace function Q5() returns integer
as
$$
declare
  r record;
  counter integer;
  nhosts integer:=0;
begin
for r in 
  select * from hosts
  where hostname ~ '.*cse.unsw.edu.au'
loop
  select count(*) into counter from sessions s
  where s.id = r.id group by s.id;
  -- raise notice 'couter %', counter;
  nhosts := nhosts + counter;
end loop;

  return nhosts;
end;
$$ language plpgsql;