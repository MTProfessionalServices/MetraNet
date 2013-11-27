
			if OBJECT_ID('%%DELTA_INSERT_TABLE_NAME%%') is not null
				if (exists (select top 1 * from %%DELTA_INSERT_TABLE_NAME%%) OR 
					exists (select top 1 * from %%DELTA_DELETE_TABLE_NAME%%)) select 'N' as empty else select 'Y' as empty
			else
				select 'Y' as empty
		