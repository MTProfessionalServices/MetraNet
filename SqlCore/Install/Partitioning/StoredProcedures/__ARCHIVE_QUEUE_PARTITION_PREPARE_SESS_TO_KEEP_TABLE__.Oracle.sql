CREATE OR REPLACE
PROCEDURE arch_q_p_prep_sess_to_keep_tab(
	p_old_partition					INT,
	p_table_name					VARCHAR2,
	table_with_sess_to_keep			VARCHAR2
)
AUTHID CURRENT_USER
AS
	preserved_partition				INT := p_old_partition - 1;
	WHERE_clause_for_sess_to_keep	VARCHAR2(1000);
	sqlCommand						VARCHAR2(4000);
BEGIN

	IF p_table_name = 'T_SESSION_SET' THEN
		WHERE_clause_for_sess_to_keep  :=
		' WHERE  tab.id_ss IN (SELECT s.id_ss
							FROM   tt_id_sess_to_keep t
								JOIN t_session s
									ON  s.id_source_sess = t.id_sess)';
	ELSIF p_table_name = 'T_SESSION_STATE' THEN
		WHERE_clause_for_sess_to_keep  :=
		' WHERE tab.id_sess IN (SELECT t.id_sess
			FROM   tt_id_sess_to_keep t)';
	ELSIF p_table_name = 'T_MESSAGE' THEN
		WHERE_clause_for_sess_to_keep  :=
		' WHERE tab.id_message IN (SELECT ss.id_message
								FROM   t_session_set ss
									   JOIN t_session s
											ON  s.id_ss = ss.id_ss
									   JOIN tt_id_sess_to_keep t
											ON  s.id_source_sess = t.id_sess)';
	/* For T_SESSION and all T_SVC_* tables using default WHERE clause */
	ELSE
		WHERE_clause_for_sess_to_keep  :=
		' WHERE tab.id_source_sess IN (SELECT t.id_sess
		   FROM   tt_id_sess_to_keep t)';
	END IF;
	
    BEGIN
        EXECUTE IMMEDIATE 'DROP TABLE ' || table_with_sess_to_keep;
    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
    END;
	
  DBMS_OUTPUT.ENABLE(1000000);
	DBMS_OUTPUT.PUT_LINE('	Preparing "' || table_with_sess_to_keep || '" for EXCHANGE PARTITION operation...');
    /* Create temp table for storing sessions that should not be deleted */
    sqlCommand :=  'CREATE TABLE ' || table_with_sess_to_keep
                || ' AS SELECT * FROM ' || p_table_name || ' tab '
				|| WHERE_clause_for_sess_to_keep
                || ' AND id_partition = ' || preserved_partition;
    EXECUTE IMMEDIATE sqlCommand;

    sqlCommand :=  'UPDATE ' || table_with_sess_to_keep
                || ' SET id_partition =  ' || p_old_partition;
    EXECUTE IMMEDIATE sqlCommand;

    sqlCommand :=  'INSERT INTO ' || table_with_sess_to_keep
                || ' SELECT * FROM ' || p_table_name || ' tab '
				|| WHERE_clause_for_sess_to_keep
                || ' AND id_partition = ' || p_old_partition;
    EXECUTE IMMEDIATE sqlCommand;

	arch_q_p_clone_ind_and_cons(
		SOURCE_TABLE => p_table_name,
		DESTINATION_TABLES => str_tab( table_with_sess_to_keep ) );
END;
