
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


