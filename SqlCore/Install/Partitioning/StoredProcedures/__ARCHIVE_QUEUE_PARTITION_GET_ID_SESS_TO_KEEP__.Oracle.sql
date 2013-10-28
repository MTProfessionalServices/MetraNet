CREATE OR REPLACE 
PROCEDURE arch_q_p_get_id_sess_to_keep(
	p_old_id_partition		INT
)
AUTHID CURRENT_USER
AS
	max_time				DATE	:= dbo.mtmaxdate();
	preserved_id_partition	INT		:= p_old_id_partition - 1;
	sql_stmt				VARCHAR2(4000);
	sess_count				INT;
BEGIN

	DBMS_OUTPUT.PUT_LINE('Starting population of "tt_id_sess_to_keep" table...');

	BEGIN
		EXECUTE IMMEDIATE 'DROP TABLE tt_id_sess_to_keep';
	EXCEPTION
	  WHEN OTHERS THEN
		IF SQLCODE != -942 THEN
			RAISE;
		END IF;
	END;

	sql_stmt := 'CREATE TABLE tt_id_sess_to_keep AS
		SELECT DISTINCT(id_sess)
		FROM t_session_state st
		WHERE  st.id_partition IN (' || p_old_id_partition || ', ' || preserved_id_partition || ')
			AND tx_state IN (''F'', ''R'')
			AND dt_end = TO_TIMESTAMP('''
			|| TO_CHAR(max_time, 'dd/mm/yyyy hh24:mi')
			|| ''', ''dd/mm/yyyy hh24:mi'')';

	-- dbms_output.put_line( sql_stmt );
	EXECUTE IMMEDIATE sql_stmt;

	sql_stmt := 'INSERT INTO tt_id_sess_to_keep
	SELECT sess.id_source_sess
	FROM   t_session sess
	WHERE  sess.id_partition IN ('|| p_old_id_partition || ', ' || preserved_id_partition || ')
		   AND NOT EXISTS (
				   SELECT 1
				   FROM   t_session_state st
				   WHERE  st.id_partition IN (' || p_old_id_partition || ', ' || preserved_id_partition || ')
						  AND st.id_sess = sess.id_source_sess
			   )';

	-- dbms_output.put_line( sql_stmt );
	EXECUTE IMMEDIATE sql_stmt;

	sql_stmt := 'INSERT INTO tt_id_sess_to_keep
	SELECT DISTINCT(ts.id_source_sess)
	FROM   t_usage_interval ui
		   JOIN t_acc_usage au
				ON  au.id_usage_interval = ui.id_interval
		   JOIN t_session ts
				ON  ts.id_source_sess = au.tx_UID
	WHERE  ts.id_partition IN (' || p_old_id_partition || ', ' || preserved_id_partition || ')
		   AND ui.tx_interval_status <> ''H''';

	-- dbms_output.put_line( sql_stmt );
	EXECUTE IMMEDIATE sql_stmt;

	EXECUTE IMMEDIATE 'CREATE INDEX pk_tt_id_sess_to_keep ON tt_id_sess_to_keep(id_sess)';

	EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM tt_id_sess_to_keep' INTO sess_count;

	DBMS_OUTPUT.PUT_LINE('Population of "tt_id_sess_to_keep" table finished. ');
	DBMS_OUTPUT.PUT_LINE( sess_count || ' sessions of partitions P' || preserved_id_partition || ' and P' || p_old_id_partition
		|| ' will be preserved in partition P' || p_old_id_partition);
END;
