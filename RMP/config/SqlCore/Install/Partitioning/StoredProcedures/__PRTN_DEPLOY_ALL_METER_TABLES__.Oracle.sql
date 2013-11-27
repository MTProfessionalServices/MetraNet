/*
  Proc: prtn_deploy_all_meter_tables

  Calls prtn_deploy_serv_def_table for Meter partitioned tables.
*/
CREATE OR REPLACE 
PROCEDURE prtn_deploy_all_meter_tables
authid current_user
AS
	current_id_part INT;
BEGIN

	/* Abort if system isn't enabled for partitioning */
	IF dbo.IsSystemPartitioned() = 0 THEN
		raise_application_error(-20000, 'System not enabled for partitioning.');
	END IF;

	dbms_output.put_line('prtn_deploy_all_meter_tables: Starting depolying meter tables');

	FOR x IN (	SELECT   nm_table_name
				FROM     t_service_def_log
				ORDER BY nm_table_name)
	LOOP
		prtn_deploy_serv_def_table(	p_tab => x.nm_table_name );
	END LOOP;

	/* Deploy message and session tables */
	prtn_deploy_serv_def_table(p_tab => 't_message');
	prtn_deploy_serv_def_table(p_tab => 't_session');
	prtn_deploy_serv_def_table(p_tab => 't_session_set');
	prtn_deploy_serv_def_table(p_tab => 't_session_state');

END prtn_deploy_all_meter_tables;
