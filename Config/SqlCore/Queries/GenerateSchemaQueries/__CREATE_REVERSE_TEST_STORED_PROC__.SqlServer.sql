
			create procedure ReverseTestStoredProc(@ID_BILLGROUP int, @ID_RUN int, @NETMETER_DB_NAME nvarchar(123))
		  	as
			begin
				declare @strQuery nvarchar(3000)
				set @strQuery = 'delete ta from t_rpt_test_account ta where ta.BillgroupID = '
							  + CAST(@ID_BILLGROUP AS nvarchar(20))
				exec sp_executesql @strQuery

				declare @strRunID nvarchar(20)
				set @strRunID = CAST(@ID_RUN AS nvarchar(20))
				set @strQuery = 'insert into ' + @NETMETER_DB_NAME + '..t_recevent_run_details values (CAST(' +@strRunID+ ' AS INTEGER), ''Info'', ''done testing reverse idrun'' , ''2004-05-07 13:48:16.717'' )'
				exec sp_executesql @strQuery
			end
	   