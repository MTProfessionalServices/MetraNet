CREATE OR REPLACE
PROCEDURE arch_q_p_switch_out_part_all(
	p_old_id_partition	INT
)
authid current_user
AS
    preserved_partition	INT	:= p_old_id_partition - 1;
	v_tab_name			VARCHAR2(30);
	v_temp_tab_name		VARCHAR2(30);
    cur_keep_sess_tabs	SYS_REFCURSOR;
BEGIN
	DBMS_OUTPUT.put_line ('Starting switching out old data for all Meter tables...');

    OPEN cur_keep_sess_tabs FOR 'SELECT TAB_NAME, TEMP_TAB_NAME FROM tt_tab_names_with_sess_to_keep';
    LOOP
		FETCH cur_keep_sess_tabs INTO v_tab_name, v_temp_tab_name;
		EXIT WHEN cur_keep_sess_tabs%NOTFOUND;

		/* EXCHANGE 'Old' partition and table with sessions to keep ('Old' becomes a new 'Preserved' partition) */
		DBMS_OUTPUT.PUT_LINE('	Processing "' || v_tab_name || '"...');
		EXECUTE IMMEDIATE 'ALTER TABLE ' || v_tab_name
						|| ' EXCHANGE PARTITION P' || p_old_id_partition
						|| ' WITH TABLE ' || v_temp_tab_name
						|| ' INCLUDING INDEXES '
						|| ' WITHOUT VALIDATION';

		/* Drop old 'Preserved' partition. As it's data was copied to next 'Preserved' partition or going to be archived.*/
		BEGIN
			EXECUTE IMMEDIATE 'ALTER TABLE ' || v_tab_name || ' DROP PARTITION P' || preserved_partition;
		EXCEPTION
		  WHEN OTHERS THEN
			/* Ignore exception "ORA-02149: Specified partition does not exist" */
			IF SQLCODE != -2149 THEN
				RAISE;
			END IF;
		END;
    END LOOP;
	CLOSE cur_keep_sess_tabs;

	DBMS_OUTPUT.put_line ('Old data was switched out from all Meter tables.');
END;