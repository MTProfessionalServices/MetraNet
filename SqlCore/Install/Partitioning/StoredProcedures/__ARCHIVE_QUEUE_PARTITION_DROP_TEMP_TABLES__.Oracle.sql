CREATE OR REPLACE
PROCEDURE arch_q_p_drop_temp_tables(
	p_old_id_partition	INT
)
authid current_user
AS
    preserved_partition	INT	:= p_old_id_partition - 1;
	v_temp_tab_name		VARCHAR2(30);
    cur_keep_sess_tabs	SYS_REFCURSOR;
BEGIN
	DBMS_OUTPUT.put_line ('Dropping of temp.tables with switched out Meter data...');

    OPEN cur_keep_sess_tabs FOR 'SELECT TEMP_TAB_NAME FROM tt_tab_names_with_sess_to_keep';
    LOOP
		FETCH cur_keep_sess_tabs INTO v_temp_tab_name;
		EXIT WHEN cur_keep_sess_tabs%NOTFOUND;

		/* Drop table with exchanged data of 'Old' partition */
		EXECUTE IMMEDIATE 'DROP TABLE ' || v_temp_tab_name;
    END LOOP;
	CLOSE cur_keep_sess_tabs;

	DBMS_OUTPUT.put_line ('Switched out Meter data was dropped.');
END;
