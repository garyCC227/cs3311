-- order i think it's matter!!
CREATE table Branches(
  branchName text,
  address text,
  assets integer,
  primary key (branchName)
)

CREATE TABLE Accounts(
  -- accountNo text primary key, (sounn a bad design)
  accountNo   text,
  branchName  text,
  balance     integer,

  foreign key (branchName) REFERENCES Branches (branchName),
  primary key (accountNo)
)

Create table Customer(
  customerNo  INTEGER,
  name        text,
  address     text,
  homeBranch  text,
  PRIMARY key (customerNo),
  foreign key (homeBranch) REFERENCES Branches (branchName)
)

Create table heldBy(
  account text,
  customer integer,
  PRIMARY key (account, customer),
  FOReign key (account) REFERENCES Account(accountNo),
  FOREIGN key (customer) REFERENCES Customer(customerNo)
)