
			begin
			  if table_exists('%%PRODUCT_VIEW_NAME%%') then
			    exec_ddl('drop table %%PRODUCT_VIEW_NAME%%');
			  end if;
			end;          
			