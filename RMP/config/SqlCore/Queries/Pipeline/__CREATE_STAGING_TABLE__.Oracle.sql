
DECLARE cnt NUMBER;	  
begin
  if not table_exists('%%%NETMETERSTAGE_PREFIX%%%%%TABLE%%') then
      execute immediate 'create table %%%NETMETERSTAGE_PREFIX%%%%%TABLE%%
        as SELECT * FROM %%%NETMETER_PREFIX%%%%%SOURCETABLE%% WHERE 0=1';
	
	  select count(1) into cnt from ALL_TAB_COLUMNS WHERE table_name = UPPER(REPLACE('%%SOURCETABLE%%','.',''))
	  AND UPPER(table_name) IN ('T_SESSION','T_SESSION_STATE','T_MESSAGE','T_SESSION_SET')
	  AND OWNER = UPPER(REPLACE('%%%NETMETER_PREFIX%%%','.','')) AND COLUMN_NAME = 'ID_PARTITION';
	  
	  if cnt > 0 then
		execute immediate 'ALTER TABLE %%%NETMETERSTAGE_PREFIX%%%%%TABLE%% DROP COLUMN ID_PARTITION'; 
	  end if;
  end if;
end;
			