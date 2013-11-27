
		Create or replace procedure Abandon (p_rerun_table_name varchar2,  p_id_rerun number, p_return_code OUT number)
		as
			v_sql varchar2(100);
			p_source_table_name varchar2(100);
			p_UIDTableName varchar2(100);
        Begin
			v_sql := 'drop table ' || p_rerun_table_name;
			execute immediate v_sql;

		p_source_table_name := N't_source_rerun_session_' || to_char(p_id_rerun);
		if table_exists (p_source_table_name)
		THEN
					EXECUTE IMMEDIATE 'DROP TABLE p_source_table_name';
		END IF;

    p_UIDTableName := N't_UIDList_' + to_char(p_id_rerun);
		if table_exists (p_UIDTableName)
		THEN
					EXECUTE IMMEDIATE 'DROP TABLE p_UIDTableName';
		END IF;

			p_return_code := 0;
		End;
    