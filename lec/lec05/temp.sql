CREATE FUNCTION temp2(_hi integer) RETURNS setof integer AS
$$
declare 
  i integer;
  sum integer := 0;
BEGIN
  for i in 1.._hi
  loop
    sum := sum + i;
  end loop;
  return next sum;
END
$$
LANGUAGE plpgsql;