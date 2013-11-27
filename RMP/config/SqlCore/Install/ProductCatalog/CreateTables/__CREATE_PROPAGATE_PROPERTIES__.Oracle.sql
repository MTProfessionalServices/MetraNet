
			create or replace procedure PropagateProperties(table_name varchar2,
			update_list varchar2,
			insert_list varchar2,
			clist  varchar2,
			temp_id_pi_template int)
			as
			idInst int;
			status int;
			cursor CursorVar is
			select id_pi_instance from t_pl_map
			where id_pi_template = temp_id_pi_template and id_paramtable is null;
			begin
				OPEN CursorVar;
				loop
				FETCH CursorVar into idInst;
				exit when CursorVar%notfound;
				ExtendedUpsert(table_name, update_list, insert_list, clist, idInst, status);
				if status <> 0 then
					raise_application_error(-20001, 'Cannot insert data into [' || table_name || '], error ' || status);
				end if;
				end loop;
				CLOSE CursorVar;
		  end;
		