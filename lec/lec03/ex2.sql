-- CREATE table p1(
--   x INTEGER,
--   y INTEGER
-- );

-- CREATE table p2(
--   x INTEGER PRIMARY key,
--   y INTEGER
-- );

create table Students(
  id serial,
  name text,
  address text,
  primary key (id)
);

