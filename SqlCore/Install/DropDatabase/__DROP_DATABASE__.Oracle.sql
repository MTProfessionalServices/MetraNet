
					declare
						v_tab varchar(500);
					begin
						select tablespace_name into v_tab
						from sys.dba_tablespaces
						where lower(tablespace_name) = lower('%%DATABASE_NAME%%');

						execute immediate 'drop tablespace %%DATABASE_NAME%% including contents and datafiles';
					exception
						when no_data_found then
   						null;
						when others then
							raise;
					end;
       