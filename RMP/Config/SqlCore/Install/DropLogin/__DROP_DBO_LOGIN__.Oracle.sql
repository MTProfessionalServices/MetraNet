
				declare
					v_name varchar(500);
				begin
					select username into v_name
					from sys.all_users
					where lower(username) = lower('%%DBO_LOGON%%');

					execute immediate 'drop user %%DBO_LOGON%% cascade';
				exception
					when no_data_found then
   					null;
					when others then
						raise too_many_rows;
				end;
       