-- 1.
select count(*) from accesses 
where acctime::text ~ '2005-03-02.*';


-- 2.
select count(*) from accesses where
page ~* 'webgms/messageboard/index'
and params ~* '.*state=search.*';


--3.