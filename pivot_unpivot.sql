--- Function pivot / unpivot
drop function if exists pivot;
create or replace function pivot(query text) returns text as $$
-- query must be pass id, category and value columms.
declare
	q text :='select id';
	r record;
begin 
	drop table if exists tmp_1, pivot_;
	execute 'create temp table tmp_1 as ' || query;
	for r in (select distinct category from tmp_1) loop
		select q || ', max(case when category=''' || r.category || ''' then value end) as ' || replace(replace(r.category,' ','_'),'-','_') into q;
	end loop;	
	execute 'create temp table pivot_ as ' || q || ' from tmp_1 group by id';
	return 'Execute SELECT * FROM pivot_';
end;
$$ language plpgsql;

drop function if exists unpivot;
create or replace function unpivot(query text) returns text as $$
-- query must be pass id and columms.
declare
	q text:='';
	r record;
	num_cols integer;
	id text;
	c text;
begin 
	drop table if exists tmp_1, unpivot_;
	execute 'create temp table tmp_1 as ' || query;
	SELECT count(*)    INTO num_cols from information_schema.columns where table_name = 'tmp_1';
	SELECT column_name into id       from information_schema.columns where table_name = 'tmp_1' limit 1 offset 0;
 	FOR i IN 2 .. num_cols loop
		SELECT column_name into c       from information_schema.columns where table_name = 'tmp_1' limit 1 offset i-1;
	 	q := q || 'select ' || id || ',''' || c || ''' as category,' || c || ' as value from tmp_1';
	 	if i < num_cols then
	 		q := q || ' union all ';
	 	end if;
	end loop;
	execute 'create temp table unpivot_ as ' || q;
	return 'Execute SELECT * FROM unpivot_';
end;
$$ language plpgsql;

-- Tests
drop table if exists foo;
CREATE TEMP TABLE foo (id int, a text, b text, c text);
INSERT INTO foo VALUES (1, 'ant', 'cat', 'chimp'), (2, 'grape', 'mint', 'basil');
select * from foo;
select unpivot('select * from foo');
select * from unpivot_;
select pivot('select * from unpivot_');
select * from pivot_;
