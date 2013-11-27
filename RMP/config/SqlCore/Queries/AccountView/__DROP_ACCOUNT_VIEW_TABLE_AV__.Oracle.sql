
declare
	pragma autonomous_transaction;
begin			
	for x in (select table_name from user_tables where upper(table_name) = upper('%%ACCOUNT_VIEW_TABLENAME%%')) loop
		execute immediate 'drop table %%ACCOUNT_VIEW_TABLENAME%%';
	end loop; 
end;
			