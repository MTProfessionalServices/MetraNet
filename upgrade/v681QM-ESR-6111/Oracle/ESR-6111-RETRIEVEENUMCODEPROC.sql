create or replace procedure retrieveenumcodeproc 
	(p_enum_string VARCHAR2, p_id_mv out sys_refcursor) as
	begin
		OPEN p_id_mv for 
		SELECT id_enum_data  from t_enum_data 
		where upper(nm_enum_data) = upper(p_enum_string);
	end;