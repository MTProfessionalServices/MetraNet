
				declare temp_sql_string as varchar(8000);
				begin
				CreateRefMatchSQL('%%TABLE_NAME%%','%%TABLE_NAME%%1','%%TABLE_NAME%%2',temp_sql_string);
				dbms_output.put_line(temp_sql_string);
				end;
			