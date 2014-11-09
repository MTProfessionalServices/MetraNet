/* [TBD] Remove all usage of temp preserved table, as looks like it's not needed */

CREATE OR REPLACE
PROCEDURE arch_q_p_prep_all_keep_ses_tab(
	p_old_id_partition	INT
)
AUTHID CURRENT_USER
AS
	v_tab_name			VARCHAR2(30);
	v_temp_tab_name		VARCHAR2(30);
    cur_keep_sess_tabs	SYS_REFCURSOR;
	old_part_row_count	INT := 0;
	pres_part_row_count	INT := 0;
	kept_row_count		INT := 0;
	rows_to_archive		INT := 0;
BEGIN

	DBMS_OUTPUT.put_line ('Preparation of table that will bind meter table names with auto-generated unique temp-table names...');
	LOOP
		BEGIN
			EXECUTE IMMEDIATE 'DROP TABLE tt_tab_names_with_sess_to_keep';
		EXCEPTION
		  WHEN OTHERS THEN
			IF SQLCODE != -942 THEN
				RAISE;
			END IF;
		END;

		EXECUTE IMMEDIATE 'CREATE TABLE tt_tab_names_with_sess_to_keep
		AS
		SELECT UPPER(nm_table_name) TAB_NAME, SUBSTR(UPPER(nm_table_name), 0, 20) || DBMS_RANDOM.string(''x'',10) TEMP_TAB_NAME
		FROM t_service_def_log
		UNION ALL
		SELECT ''T_SESSION'', ''T_SESSION'' || DBMS_RANDOM.string(''x'',10) FROM dual
		UNION ALL
		SELECT ''T_SESSION_SET'', ''T_SESSION_SET'' || DBMS_RANDOM.string(''x'',10) FROM dual
		UNION ALL
		SELECT ''T_SESSION_STATE'', ''T_SESSION_STATE'' || DBMS_RANDOM.string(''x'',10) FROM dual
		UNION ALL
		SELECT ''T_MESSAGE'', ''T_MESSAGE'' || DBMS_RANDOM.string(''x'',10) FROM dual';

		/* Ensure auto-generated names are unique */
		BEGIN
			EXECUTE IMMEDIATE'ALTER TABLE tt_tab_names_with_sess_to_keep ADD CONSTRAINT cons_check_unique UNIQUE (TEMP_TAB_NAME)';
			EXECUTE IMMEDIATE'ALTER TABLE tt_tab_names_with_sess_to_keep DROP CONSTRAINT cons_check_unique';
			EXIT;
		EXCEPTION
		  WHEN OTHERS THEN
			IF SQLCODE != -2299 THEN
				RAISE;
			END IF;
			/* Recreate "tt_tab_names_with_sess_to_keep" if "TEMP_TAB_NAME" is not unique */
		END;
    END LOOP;

	DBMS_OUTPUT.put_line ('Preparation of temp tables with sessions to keep...');

    OPEN cur_keep_sess_tabs FOR 'SELECT TAB_NAME, TEMP_TAB_NAME FROM tt_tab_names_with_sess_to_keep';
    LOOP
		FETCH cur_keep_sess_tabs INTO v_tab_name, v_temp_tab_name;
		EXIT WHEN cur_keep_sess_tabs%NOTFOUND;

		arch_q_p_prep_sess_to_keep_tab(
			p_old_partition => p_old_id_partition,
			p_table_name => v_tab_name,
			table_with_sess_to_keep => v_temp_tab_name );

		EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_temp_tab_name INTO kept_row_count;
		EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_name || ' PARTITION (P' || p_old_id_partition || ')' INTO old_part_row_count;

		BEGIN
			EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_name || ' PARTITION (P' || (p_old_id_partition - 1) || ')' INTO pres_part_row_count;
		EXCEPTION
		  WHEN OTHERS THEN
			/* Ignore exception "ORA-02149: Specified partition does not exist" */
			IF SQLCODE != -2149 THEN
				RAISE;
			END IF;
		END;

    DBMS_OUTPUT.ENABLE(1000000);
		rows_to_archive := (old_part_row_count + pres_part_row_count) - kept_row_count;
		DBMS_OUTPUT.put_line ('<' || rows_to_archive || '> rows should be archived from "' || v_tab_name || '" table.');

    END LOOP;
	CLOSE cur_keep_sess_tabs;

	DBMS_OUTPUT.put_line ('All temp tables with sessions to keep prepared.');
END;
