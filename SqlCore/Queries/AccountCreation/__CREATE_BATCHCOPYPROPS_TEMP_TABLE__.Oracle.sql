
					begin 
					  /*__CREATE_BATCHCOPYPROPS_TEMP_TABLE__*/
						if table_exists('%%TMP_TABLE_NAME%%') then
						  execute immediate 'drop table %%TMP_TABLE_NAME%%';
						end if;
					  execute immediate 'create table %%TMP_TABLE_NAME%%
        