
-- q1 sections
create or replace view Enrolled
as
select course_id, count(*) as num from course_enrolments 
group by course_id;


-- q4 sections
--view for numebr of enroll in each course
create or replace view NumEnroll
as
select course_id, count(*) as num from course_enrolments
group by course_id;

--q5 sections
--view for numer of enrollment in each class
create or replace view classEnroll
as 
select class_id, count(*) as num 
from class_enrolments
group by class_id;


--q7 sections
-- binary string OR funciton
-- create or replace function BinaryOR(left_ text, right_ text) returns text
-- as
-- $$
-- declare
--   result text = '';
--   r_arr text[];
--   l_arr text[];
--   i int;
-- begin
--   if left_ = '' then
--     return right_;
--   end if;

--   select regexp_split_to_array(left_,'') into l_arr;
--   select regexp_split_to_array(right_,'') into r_arr;
--   for i in 1..11
--   loop
--     if l_arr[i] = '1' or r_arr[i] = '1' then
--       result = result || '1';
--     else
--       result = result || '0';
--     end if;
--   end loop;
--   return result;
-- end;
-- $$ language plpgsql;

-- drop aggregate if exists BinaryORRows(text);

-- create aggregate BinaryORRows(text)(
--   stype = text,
--   initcond = '',
--   sfunc = BinaryOR
-- );

--view for room used in 19T3
create or replace view T3Rooms
as
select 
  r.code as room,
  T3Class.term,
  m.day,
  m.start_time as starting,
  m.end_time as ending,
  m.weeks_binary as weeks
from meetings m 
join
  (
    select c.id as class_id, T3C.name as term from classes c 
    join
      (select c.id, t.name from courses c 
      join terms t on c.term_id = t.id
      where t.name='19T3') as T3C
    on T3C.id = c.course_id
  ) as T3Class
on T3Class.class_id = m.class_id
join rooms r on r.id = m.room_id
where r.code ~* '^K-.*'
order by
r.code, m.day, m.start_time, m.end_time;


create or replace view T2Rooms
as
select 
  r.code as room,
  T3Class.term,
  m.day,
  m.start_time as starting,
  m.end_time as ending,
  m.weeks_binary as weeks
from meetings m 
join
  (
    select c.id as class_id, T3C.name as term from classes c 
    join
      (select c.id, t.name from courses c 
      join terms t on c.term_id = t.id
      where t.name='19T2') as T3C
    on T3C.id = c.course_id
  ) as T3Class
on T3Class.class_id = m.class_id
join rooms r on r.id = m.room_id
where r.code ~* '^K-.*'
order by
r.code, m.day, m.start_time, m.end_time;

create or replace view T1Rooms
as
select 
  r.code as room,
  T3Class.term,
  m.day,
  m.start_time as starting,
  m.end_time as ending,
  m.weeks_binary as weeks
from meetings m 
join
  (
    select c.id as class_id, T3C.name as term from classes c 
    join
      (select c.id, t.name from courses c 
      join terms t on c.term_id = t.id
      where t.name='19T1') as T3C
    on T3C.id = c.course_id
  ) as T3Class
on T3Class.class_id = m.class_id
join rooms r on r.id = m.room_id
where r.code ~* '^K-.*'
order by
r.code, m.day, m.start_time, m.end_time;

-- better view for room used in 19T3
-- no double booking, no overlap class which has the same start_time and end_time
-- create or replace view T3Rooms2
-- as
-- select room,day,starting,ending, BinaryORrows(weeks) from T3rooms 
-- group by room, day, starting, ending;


-- Count total Room- 508
select sum(count) from (
(select count(*) from rooms where code ~* '^K-.*' group by id)) as Foo;


