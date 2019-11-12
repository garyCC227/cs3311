-- 1. 
-- Yes, we cannot reference a foreign key in table A if we haven't carete table A

-- 2.
update employees
set salary =salary * 0.8
where age < 25;


-- 3. review

create table Departments (
      did       integer,
      dname     varchar(20),
      budget    real,
      manager   integer not null,
      primary key (did),
      foreign key (manager) references Employees(eid)
   );

--4.
create table Employees (
   eid       integer,
   ename     varchar(30),
   age       integer,
   salary    real check (salary >= 15000),
   primary key (eid),
);

create table WorksIn (
   eid         integer,
   did         integer,
   pct_time    real,
   primary key (eid,did),
   foreign key (eid) references Employees(eid),
   foreign key (did) references Departments(did)
   constraint MaxFullTimeCheck
              check (1.00 >=  (select sum(w.pct_time)
                              from WorksIn w
                              where w.eid = eid))
);


--8.
create table WorksIn (
   eid         integer,
   did         integer,
   pct_time    real,
   primary key (eid,did),
   foreign key (eid) references Employees(eid) on delete cascade,
   foreign key (did) references Departments(did)
);

--9. review
-- since we already set NOT NULL for manager,
-- so we can just set manager to some never use value


-- --10. review
-- since WorksIn depend on both Departments and Employees.
-- we can set it to on delete cascade 
create table WorksIn (
   eid       integer,
   did       integer,
   pct_time  real,
   primary key (eid,did),
   foreign key (eid) references Employees(eid) on delete cascade,
   foreign key (did) references Departments(did) on delete cascade
);
-- or set it to on delete set default
create table WorksIn (
   eid       integer,
   did       integer default 1,
   pct_time  real,
   primary key (eid,did),
   foreign key (eid) references Employees(eid) on delete cascade,
   foreign key (did) references Departments(did) on delete set default
);


--11. review


-- 12. 
create table R (
        x       integer,
        y       char(1),
	primary key (x),
	foreign key (y) references S(y)
);
create table S (
        y       char(1),
        x       integer,
	primary key (y),
	foreign key (x) references R(x)
);

-- solutions:
alter table R 
add
foreign key (y) references S(y);


alter table S 
add
foreign key (y) references R(y);

--13.
insert into R values (1,null);
insert into S values ('a',null);
update R set y = 'a' where x = 1;
update S set x = 1 where y = 'a';


--14.

--NOTE: deferred/ immediate 
-- Upon creation, a constraint is given one of three characteristics: DEFERRABLE INITIALLY DEFERRED, DEFERRABLE INITIALLY IMMEDIATE, or NOT DEFERRABLE. 
-- The third class is always IMMEDIATE and is not affected by the SET CONSTRAINTS command.
--  The first two classes start every transaction in the indicated mode, but their behavior c
--  an be changed within a transaction by SET CONSTRAINTS.
ALTER TABLE foo
  ADD CONSTRAINT foo_bar_fk
  FOREIGN KEY (bar_id) REFERENCES bar (id)
  DEFERRABLE INITIALLY IMMEDIATE; -- the magic line
-- currently is immediate, can change later

--NOTE:
-- DEFERRABLE INITIALLY IMMEDIATE
-- INITIALLY DEFERRED
--  DEFERRABLE
-- NOT DEFERRABLE

-- must use ' deferrable' --> if concurrency
begin;   -- start a transaction
set constraints all deferred;!!!
insert into R values (1,'a');
insert into S values ('a',1);
commit;  -- finish the transaction