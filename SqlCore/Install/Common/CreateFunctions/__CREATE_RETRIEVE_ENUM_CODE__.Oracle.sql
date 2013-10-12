CREATE OR REPLACE
FUNCTION RetrieveEnumCode
	(
		p_enum_string VARCHAR2
	) RETURN INTEGER
	IS
	p_return_enum INTEGER;
	BEGIN
		SELECT id_enum_data INTO p_return_enum FROM t_enum_data WHERE upper(nm_enum_data) = upper(p_enum_string);
		RETURN p_return_enum;
	END;
		