
CREATE OR REPLACE PROCEDURE mt_sys_analyze_all_tables (
   username           VARCHAR2 DEFAULT NULL,
   p_sampling_ratio   VARCHAR2 DEFAULT '20'
)
AS /* How to run this stored procedure        begin       MT_sys_analyze_all_tables;       end;       */
   v_user_name   VARCHAR2 (30);
   v_sql         VARCHAR2 (4000);
BEGIN
   IF (username IS NULL)
   THEN
      SELECT SYS_CONTEXT ('USERENV', 'SESSION_USER')
        INTO v_user_name
        FROM DUAL;
   END IF;

   v_sql :=
         'begin dbms_stats.gather_schema_stats(
					ownname=> '''
      || v_user_name
      || ''',
					estimate_percent=> '
      || p_sampling_ratio
      || ',
					degree=> dbms_stats.auto_degree,
					granularity=> ''AUTO'',
					method_opt=> ''FOR ALL COLUMNS SIZE 1'',
					options=> ''GATHER'',
					cascade=> TRUE); end;';

   EXECUTE IMMEDIATE v_sql;
END;
	