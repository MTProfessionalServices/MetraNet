CREATE OR REPLACE
PROCEDURE arch_q_p_next_part_single_tab(
	p_table_name			VARCHAR2,
	p_id_partition			INT,
	p_tablespace_name		VARCHAR2,
	p_partition_field_name	VARCHAR2
)
AUTHID CURRENT_USER
AS
    sql_command				VARCHAR2(1000);
    partition_name			VARCHAR2(100);
BEGIN
	partition_name := 'p' || p_id_partition;

    DBMS_OUTPUT.PUT_LINE(
    'Applying next partition for "' || p_table_name || '" table');

    sql_command :=    ' ALTER TABLE ' || p_table_name
                   || ' ADD PARTITION ' || partition_name
                   || ' VALUES ('|| p_id_partition ||')'
                   || ' TABLESPACE ' || p_tablespace_name;
    EXECUTE IMMEDIATE sql_command;

    sql_command :=   ' ALTER TABLE ' || p_table_name
                  || ' MODIFY ' || p_partition_field_name
                  || ' DEFAULT ' || p_id_partition;
    EXECUTE IMMEDIATE sql_command;

END;