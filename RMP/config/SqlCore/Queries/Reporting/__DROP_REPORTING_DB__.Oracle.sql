
		DECLARE
		   user_count         NUMBER;
		   tablespace_count   NUMBER;
		BEGIN
		   SELECT COUNT (*)
			 INTO user_count
			 FROM all_users
			WHERE UPPER(username) = UPPER('%%REPORTING_DB_NAME%%');

		   IF (user_count >= 1)
		   THEN
			   execute immediate 'drop user %%REPORTING_DB_NAME%% cascade';
		   END IF;

		   SELECT COUNT (*)
			 INTO tablespace_count
			 FROM dba_data_files
			WHERE UPPER (tablespace_name) = UPPER('%%REPORTING_DB_NAME%%');
		   IF (tablespace_count >= 1)
		   THEN
			   execute immediate 'drop tablespace %%REPORTING_DB_NAME%% including contents and datafiles';
		   END IF;

		   EXECUTE IMMEDIATE 'delete from %%NETMETER_DB_NAME%%.t_ReportingDBLog where UPPER(NameOfReportingDB) = UPPER(''%%REPORTING_DB_NAME%%'')';
		END;
  		