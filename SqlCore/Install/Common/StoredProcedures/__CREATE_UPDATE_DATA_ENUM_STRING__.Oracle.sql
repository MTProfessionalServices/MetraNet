
			CREATE or replace PROCEDURE UpdateDataForEnumToString
			(p_table varchar2,
			p_column varchar2)
			AS
			p_query varchar2(1000);
			begin
			p_query := 'update ' || p_table || ' set ' || p_column || ' =
									(select REVERSE(to_char(substr(REVERSE(to_char(nm_enum_data)),1,
									instr(reverse(to_char(nm_enum_data)),''/'',1,1)-1)))
									from t_enum_data
									WHERE id_enum_data = ' || p_column || ')';
			execute immediate (p_query);
			end;
		