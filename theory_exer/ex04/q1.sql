-- *** 1. 

-- a. 
select sname
from   Suppliers natural join Catalog natural join Parts P
where  P.colour='red' --natural join  -> default is inner -> implicitly 
                      -- use the common column

-- b.
select sid
from   Catalog C natural join Parts P
where  (P.colour='red' or P.colour='green')

--c.
select S.sid
from   Suppliers S
where  S.address='221 Packer Street'
       or S.sid in (select C.sid
                    from   Parts P, Catalog C
                    where  P.color='red' and P.pid=C.pid
                   )