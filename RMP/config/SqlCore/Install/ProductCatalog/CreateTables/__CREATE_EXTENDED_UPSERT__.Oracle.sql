
					create or replace procedure ExtendedUpsert(
					table_name varchar2,
					update_list varchar2,
					insert_list varchar2,
					clist varchar2,
					temp_id_prop int,
					status OUT INT )
					as
					stmt varchar2(4000);
					stmt1 varchar2(4000);
					begin
					status := 0;
					stmt := 'update '||' '||table_name||' '||' set '||' '||
					update_list||' '||' where '||' '||table_name||'.id_prop = '||' '|| temp_id_prop;
					execute immediate stmt;
					if sql%notfound then
					stmt1 :='insert into '||' '||table_name||'(id_prop,'||clist||')'||' '||'values('||
					temp_id_prop||','||insert_list||')';
					execute immediate stmt1;
					end if;
					EXCEPTION WHEN OTHERS THEN status := SQLCODE;
					end;
				