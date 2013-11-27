
				create or replace procedure GetDatabaseProperty(property IN varchar2, value OUT nvarchar2, status OUT int)
				as
				begin
					select value into value from t_db_values where parameter = property;
					status := 0;
      	exception
					when no_data_found then
   					status := -99;
						return;
					when others then
						raise;
				end;
			