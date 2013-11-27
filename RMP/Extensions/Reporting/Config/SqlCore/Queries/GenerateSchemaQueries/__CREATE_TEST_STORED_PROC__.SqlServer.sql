
			create procedure TestStoredProc(@ID_BILLGROUP int, @ID_RUN int, @NETMETER_DB_NAME nvarchar(123))
		  	as
			begin
				declare @strQuery nvarchar(3000)
				set @strQuery = 'insert into t_rpt_test_account
					select amap.id_acc, bgm.id_billgroup, amap.nm_login
					from ' + @NETMETER_DB_NAME + '..t_account_mapper amap 
					inner join ' + @NETMETER_DB_NAME + '..t_billgroup_member bgm
					on amap.id_acc = bgm.id_acc
					where bgm.id_billgroup = ' + CAST(@ID_BILLGROUP AS nvarchar(20))
				exec sp_executesql @strQuery

				declare @strRunID nvarchar(20)
				set @strRunID = CAST(@ID_RUN AS nvarchar(20))
				set @strQuery = 'insert into ' + @NETMETER_DB_NAME + '..t_recevent_run_details values (CAST(' +@strRunID+ ' AS INTEGER), ''Info'', ''done testing idrun'' , ''2004-05-07 13:48:16.717'' )'
				exec sp_executesql @strQuery
			end
	   