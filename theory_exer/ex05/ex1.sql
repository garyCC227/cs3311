-- Q1
-- wont work for real number,
-- but if we change integer to numeric --> will work
create or replace function sqr(n integer) returns integer

as
$$
begin
        return n*n;
end;
$$ language plpgsql;


-- Q2
-- iterative one
create or replace function fac1(x integer) returns integer
as
$$
declare
  i integer;
  result integer;
begin
  if x < 0 then
    return null;
  end if;

  result := 1;
  for i in 1..x
  loop 
    result := result * i;
  end loop;

  return result;
end;
$$ language plpgsql;

-- recursive one
create or replace function fac2(x integer) returns integer
as
$$
begin
  if (x < 0) then 
    return null;
  elsif (x = 0) then
    return 1;
  elsif (x = 1) then
    return 1; 
  else
    return x * fac2(x-1);
  end if; 
end;
$$ language plpgsql;


-- Q3
create or replace function spread(str text) returns text
as
$$
declare
  result text := '';
  _len integer;
  i integer;
begin
  _len = length(str);
  for i in 1.._len
  loop
    result := result || substr(str,i,1) || ' ';
    i := i + 1;
  end loop;

  return result;
end;
$$ language plpgsql;

-- Q4
create type IntValue as ( val integer );
create or replace function seq(n integer) returns setof IntValue
as 
$$
declare
  i integer;
  r IntValue%rowtype;
begin
  for i in 1..n
  loop
    r.val := i;
    return next r;
  end loop;
end;
$$ language plpgsql;

--Q5
create or replace function seq(lo int,hi int, jump int) returns setof IntValue
as
$$
declare
  i integer;
  r IntValue;
begin
  i:=lo;
  if jump > 0 then
    while i <= hi
    loop
      r.val = i;
      return next r;
      i:=i+jump;
    end loop;
  else
    while i >= hi
    loop
      r.val = i;
      return next r;
      i:=i+jump;
    end loop;
  end if;
end;
$$ language plpgsql;


--Q7
-- where the product aggregate is defined as follows:
-- basetype = type of the input values
-- stype    = type of intermediate states in computing aggregate
-- sfunc    = function mapping (currentState, nextValue) -> newState
-- initcond = value for starting state
-- The "intermediate state" for computing a product is very simple.
-- It's simply the product accumulated so far. Similarly, the mapping
-- function simply multiplies the current product by the next value.
--
-- For more details on defining aggregates, see ...
--     PostgreSQL Reference Manual, SQL section

create aggregate product(int)(
  sfunc = multiply,
  stype = int,
  initcond = 1
);

create or replace function multiply(int, int) returns int
as
$$
begin
  return $1 * $2;
end;
$$ language plpgsql;


---Q9
create or replace function hotelsIn(_addr text) returns text
as
$$
declare 
  result text := '';
  r record;
begin
  for r in 
    select * from bars where addr = _addr
  loop
    result := result || r.name || E'\n';
  end loop;
  return result;
end;
$$ language plpgsql;

-- Q10
create or replace function hotelsIn1(_addr text) returns text
as
$$
declare 
  result text := 'Hotels in The Rocks:' || E'\n';
  r record;
  n integer := 1;
begin
  for r in 
    select * from bars where addr = _addr
  loop
    result := result || ' '||n || '. '|| r.name || E'\n';
    n := n + 1;
  end loop;
  if (r is null) then
    return 'There are no hotels in ' || _addr;
  else
    return result;
  end if;
end;
$$ language plpgsql;

-- Q11
create or replace function happyHourPrice(_hotel text, _beer text, _discount real)
returns text
as $$
declare
  std_price integer;
  counter integer;
  new_price real;

begin
  select into counter count(*) from Bars where name = _hotel;
  if (not found) then
    return 'There is no hotel called ' || _hotel || '.\n';
  end if;
  select into counter count(*) from Beers where name = _beer;
	if (counter = 0) then
		return 'There is no beer called '|| _beer ||'.\n';
	end if;
	select price into std_price
	from   Sells s
	where  s.beer = _beer and s.bar = _hotel;
	if (not found) then
		return 'The '|| _hotel || ' does not serve '||_beer;
	end if;
	new_price := std_price - _discount;
	if (new_price < 0) then
		return 'Price reduction is too large; '
			   || _beer || ' only costs '
			   || to_char(std_price, '$9.99');
	else	
		return 'Happy hour price for '
			   || _beer || ' at '|| _hotel ||' is '
			   || to_char(new_price, '$9.99');	
	end if;
end;
$$ language plpgsql;

-- Q12
create or replace function
	hotelsIn(text) returns setof Bars
as $$ 
	select * from Bars where addr = $1;
$$ language sql;


-- Q13
create or replace function hotelsIn2(text) returns setof Bars
as $$
declare
  r Bars%rowtype; -- or record
begin
  for r in 
    select * from Bars where addr = $1
  loop
    return next r;
  end loop;
end;
$$ language plpgsql;


-- Q15: review
-- Q16 and Q17 Q18: review