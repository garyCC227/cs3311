--- q1-3
-- create domain ANo as
--   char(5) check (value ~ '[A-Z]-[0-9]{3}');
-- create table Account(
--   branchName  text,
--   accountNo   ANo,
--   balance     INTEGER,
--   primary key (accountNo)
-- );
-- create table Owner(
--   aNo ANo,
--   customer INTEGER,
--   PRIMARY key(aNo, customer),
--   FOREIGN key(aNo) REFERENCES Account(accountNo)
-- );
-- insert into Account values
-- ('UNSW', 'U-245', 1000),
-- ('UNSW', 'U-291', 2000),
-- ('Randwick', 'R-245', 20000),
-- ('Coogee', 'C-123', 15000),
-- ('Coogee', 'C-124', 25000),
-- ('Clovelly', 'Y-123', 1000),
-- ('Maroubra', 'M-222', 5000),
-- ('Maroubra', 'M-225', 12000);
-- insert into Owner values
-- ('U-245', 12345),
-- ('U-291', 12345),
-- ('U-291', 12666),
-- ('R-245', 12666),
-- ('C-123', 32451),
-- ('C-124', 22735),
-- ('Y-123', 76543),
-- ('M-222', 92754),
-- ('M-225', 12345);
--- q4

CREATE DOMAIN UNSWID AS char(7)
CHECK (value ~* '[0-9]{7}');

CREATE TABLE Student (
  zid UNSWID,
  name text,
  age INTEGER,
  PRIMARY KEY (zid)
);

CREATE TABLE Class (
  code INTEGER PRIMARY KEY,
  name text
);

CREATE TABLE Enrolment (
  student UNSWID,
  class INTEGER,
  mark INTEGER,
  PRIMARY KEY (student, class),
  FOREIGN KEY (student) REFERENCES Student (zid),
  FOREIGN KEY (class) REFERENCES Class (code)
);

INSERT INTO Student
  VALUES ('1234567', 'Harry Roo', 21), ('2345678', 'Chen Zhang', 25), ('3456789', 'Patricia Li', 18);

INSERT INTO Class
  VALUES (3311, 'Databases with the Shepherd'), (6441, 'Security learning'), (1521, 'MIPS and fun');

INSERT INTO Enrolment (student, class)
  VALUES ('1234567', 3311);

INSERT INTO Enrolment
  VALUES ('2345678', 3311, 76), ('2345678', 1521, 77), ('2345678', 6441, 77);

INSERT INTO Enrolment (student, class)
  VALUES ('1234567', 1521);

