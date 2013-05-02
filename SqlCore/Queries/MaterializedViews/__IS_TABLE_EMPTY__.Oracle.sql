
			select case when not table_exists1('%%DELTA_INSERT_TABLE_NAME%%') = 1 then 'Y'
					    when (table_hasrows1('%%DELTA_INSERT_TABLE_NAME%%') = 1 OR 
						      table_hasrows1('%%DELTA_DELETE_TABLE_NAME%%') = 1) then 'N'
						else 'Y'
				   end as empty
			from dual
		