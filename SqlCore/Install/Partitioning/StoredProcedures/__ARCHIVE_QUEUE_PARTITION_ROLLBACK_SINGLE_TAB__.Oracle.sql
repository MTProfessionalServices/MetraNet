CREATE OR REPLACE
PROCEDURE arch_q_p_rollback_single_tab(
    p_table_name			VARCHAR2,
    p_id_partition			INT,
    p_partition_field_name	VARCHAR2
)
AUTHID CURRENT_USER
AS
    sql_command				VARCHAR2(1000);
    part_name				VARCHAR2(100);
    is_partition_exists		INT;
BEGIN
    part_name := 'P' || p_id_partition;

    DBMS_OUTPUT.PUT_LINE('Rollback next partition for "' || p_table_name || '" table');

    sql_command :=   ' ALTER TABLE ' || p_table_name
                    || ' MODIFY ' || p_partition_field_name
                    || ' DEFAULT ' || (p_id_partition - 1);
    EXECUTE IMMEDIATE sql_command;

	SELECT COUNT(1) INTO is_partition_exists
	FROM   user_tab_partitions
	WHERE  table_name = UPPER(p_table_name)
		   AND partition_name = part_name;

	IF is_partition_exists > 0 THEN

		sql_command :=   ' ALTER TABLE ' || p_table_name || ' ENABLE ROW movement';
		EXECUTE IMMEDIATE sql_command;

		sql_command :=     ' UPDATE ' || p_table_name
						|| ' PARTITION (' || part_name || ')'
						|| ' SET ' || p_partition_field_name || ' = ' || (p_id_partition - 1);
		EXECUTE IMMEDIATE sql_command;

		sql_command :=   ' ALTER TABLE ' || p_table_name || ' DISABLE ROW movement';
		EXECUTE IMMEDIATE sql_command;

		sql_command :=    ' ALTER TABLE ' || p_table_name
					   || ' DROP PARTITION ' || part_name;
		EXECUTE IMMEDIATE sql_command;
	END IF;

END;
