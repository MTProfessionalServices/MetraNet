
	   create or replace procedure CreateReportingDB (
                    p_strDBName IN nvarchar2,
                    p_strPassword IN nvarchar2,
                    p_strNetmeterDBName IN nvarchar2,
                    p_strDataLogFilePath IN nvarchar2,
                    p_dbSize IN int,
					p_return_code OUT int
                   )
        authid current_user
		as
			strDataFileName    varchar2(255);
			strDBCreateQuery   varchar2(2000);
			strAddDbToBackupQuery varchar2(2000);
			strCreateDBUser		varchar2(2000);
			strAddTableExitsQuery varchar2(2000);
			strAddObjectExitsQuery varchar2(2000);
			strSetUserProvileges varchar2(400);
			bDebug			   int;
			ErrMsg			   varchar2(200);
			v_sqlcode		   number(12);
			v_sqlerrm		   varchar2(200);
			bTablespaceCreated	boolean;
			bUserCreated		 boolean;
			FatalError exception;
		BEGIN
			bTablespaceCreated := true;
			bUserCreated := true;
			ErrMsg := NULL;
			p_return_code := 0;
			bDebug := 1;
			strDataFileName := p_strDataLogFilePath || '\' || p_strDBName || '_data.dbf';

			strDBCreateQuery := 'create tablespace '
							|| p_strDBName || ' datafile ''' || strDataFileName || ''' size '
							|| to_char(p_dbsize) || 'M REUSE AUTOEXTEND ON NEXT 100M MAXSIZE UNLIMITED '
							|| 'LOGGING EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT AUTO';

			strCreateDBUser := 'create user ' || p_strDBName || ' identified by '
							 || p_strPassword || ' default tablespace '
							 || p_strDBName || ' temporary tablespace temp quota unlimited on '
							 || p_strDBName;

			strAddDbToBackupQuery := 'insert into ' || p_strNetmeterDBName
									|| '.t_ReportingDBLog(NameOfReportingDB, doBackup)'
							        || ' Values(''' || p_strDBName || ''', ''Y'')';

			strAddTableExitsQuery := 'CREATE OR REPLACE function '|| p_strDBName || '.table_exists(tab varchar2) return boolean authid current_user'
									 || ' as exist int := 0; begin'
									 || ' select count(1) into exist from user_tables where table_name = upper(tab);'
									 || ' if (exist > 0)then return true; end if;'
									 || ' select count(1) into exist from all_tables where owner || ''.'' || table_name = upper(tab);'
									 || ' return(exist > 0); end;';

			strAddObjectExitsQuery := 'CREATE OR REPLACE function '|| p_strDBName || '.object_exists(obj varchar2) return boolean authid current_user'
								     || ' as exist int := 0; begin'
								     || ' select count (1) into exist from user_objects where object_name = upper (obj);'
									 || ' if (exist > 0) then return true; end if;'
									 || ' select count (1) into exist from all_objects where owner || ''.'' || object_name = upper(obj);'
									 || ' return (exist > 0); end;';

			/* Create the tablespace */
			begin
				if (bDebug = 1) then
					dbms_output.put_line ('About to execute create DB Query : ' || strDBCreateQuery);
				end if;

				execute immediate (strDBCreateQuery);
				exception
				when others then
					bTablespaceCreated := false;
					v_sqlcode := SQLCODE;
					v_sqlerrm := SQLERRM;
					ErrMsg := 'An error occured while creating the database: ' || p_strDBName;
					raise FatalError;
			end;

			/* Create user for tablespace. */
			begin
				if (bDebug = 1) then
					dbms_output.put_line ('About to execute create DB user Query : ' || strCreateDBUser);
				end if;
				execute immediate (strCreateDBUser);

				/* Add dbcreator role to nmdbo, used for creating datamart database later in datamart adapter */
				if (bDebug = 1) then
					dbms_output.put_line ('About to grant user privileges');
				end if;

				exception
				when others then
					bUserCreated := false;
					v_sqlcode := SQLCODE;
					v_sqlerrm := SQLERRM;
					ErrMsg := 'An error occured while creating the db user: ' || p_strDBName;
					raise FatalError;
			end;

			begin
				strSetUserProvileges := 'grant CONNECT, RESOURCE, CREATE TABLE, CREATE VIEW, EXECUTE ANY PROCEDURE,'
								  || 'SELECT ANY TABLE,SELECT ANY SEQUENCE,INSERT ANY TABLE,'
								  || 'CREATE SEQUENCE, QUERY REWRITE, CREATE MATERIALIZED VIEW to '
								  || p_strDBName;
				execute immediate(strSetUserProvileges);

				exception
				when others then
					v_sqlcode := SQLCODE;
					v_sqlerrm := SQLERRM;
					ErrMsg := 'An error occured while granting user priveleges: ' || p_strDBName;
					raise FatalError;
			end;

			/* Add 'table_exists' function. */
			begin
				if (bDebug = 1) then
					dbms_output.put_line ('About to add ''table_exists'' function.');
				end if;

				execute immediate(strAddTableExitsQuery);
				exception
				when others then
					v_sqlcode := SQLCODE;
					v_sqlerrm := SQLERRM;
					ErrMsg := 'An error occured while adding ''table_exits'' function. Database: ' || p_strDBName;
					raise FatalError;
			end;

			/* Add 'object_exists' function. */
			begin
				if (bDebug = 1) then
					dbms_output.put_line ('About to add ''object_exists'' function.');
				end if;

				execute immediate(strAddObjectExitsQuery);
				exception
				when others then
					v_sqlcode := SQLCODE;
					v_sqlerrm := SQLERRM;
					ErrMsg := 'An error occured while adding ''object_exists'' function. Database: ' || p_strDBName;
					raise FatalError;
			end;

			/* Execute database to backup db table. */
			begin
				if (bDebug = 1) then
					dbms_output.put_line ('About to execute add DB to backup table Query : ' || strAddDBToBackupQuery);
				end if;

				execute immediate(strAddDBToBackupQuery);
				exception
				when others then
					v_sqlcode := SQLCODE;
					v_sqlerrm := SQLERRM;
					ErrMsg := 'An error occured while adding database to t_ReportingDBLog table. Database: ' || p_strDBName;
					raise FatalError;
			end;

	    RETURN;

	    exception
		   when FatalError then
			if ErrMsg IS NULL then
				v_sqlcode := SQLCODE;
				v_sqlerrm := SQLERRM;
				ErrMsg := 'CreateReportingDB: stored procedure failed';
			end if;

			if (bDebug = 1) then
				dbms_output.put_line (ErrMsg || ' error code: ' || to_char(v_sqlcode) || ', ' || v_sqlerrm);
			end if;

			if (bUserCreated = true) then
				execute immediate ('drop user ' || p_strDBName ||' cascade');
			end if;

			if (bTablespaceCreated = true) then
				execute immediate ('drop tablespace ' || p_strDBName ||' including contents and datafiles');

				execute immediate ('delete from ' || p_strnetmeterdbname
								   || '.t_ReportingDBLog where NameOfReportingDB = ''' || p_strdbname || '''');
			end if;

			p_return_code := -1;
	   RETURN;
	END;
	