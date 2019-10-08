create domain PositiveIntegerValue as integer check (value > 0);
create domain UnswStudentId as char(7) check (value ~ '[0-9]{7}');
create domain UnswCourseCode as char(8) check (value ~ '^[A-Z]{4}[0-9]{4}$');
create domain UnswGradesDomain as
	char(2) check (value in ('FL','PS','CR','DN','HD'));

create type Color as enum('red', 'green', 'yellow');
	-- CR < DN < FL < HD < PS


create table enrol(
  student UnswStudentId,
  course UnswCourseCode,
  grade   integer references UnswGrades(id),
	mark    integer check (mark between 0 and 100)
  -- primary key (student, course, term)
);