CREATE OR REPLACE
FUNCTION RetrieveEnumCode
(
  enum_string VARCHAR2
)
RETURN INTEGER
IS
return_enum INTEGER;
BEGIN
  SELECT id_enum_data INTO return_enum 
  FROM t_enum_data 
  WHERE upper(nm_enum_data) = upper(enum_string);
  RETURN return_enum;
END;
		