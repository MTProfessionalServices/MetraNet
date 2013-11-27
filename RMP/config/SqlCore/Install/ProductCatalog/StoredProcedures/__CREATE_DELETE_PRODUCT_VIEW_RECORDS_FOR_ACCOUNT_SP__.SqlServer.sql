
				CREATE PROC DelPVRecordsForAcct
										@nm_productview varchar(255),
										@id_pi_template int,
										@id_interval int,
										@id_view int,
										@id_acc int
				AS
				DECLARE @pv_delete_stmt varchar(1000)
 				DECLARE @usage_delete_stmt varchar(1000)
 				DECLARE @strInterval varchar(255)
 				DECLARE @strPITemplate varchar(255)
 				DECLARE @strView varchar(255)
 				DECLARE @strAccount varchar(255)
 				DECLARE @WhereClause varchar(255)

				--convert int to strings
				SELECT @strInterval = CONVERT(varchar(255), @id_interval)
				SELECT @strPITemplate = CONVERT(varchar(255), @id_pi_template)
				SELECT @strView = CONVERT(varchar(255), @id_view)
				SELECT @strAccount = CONVERT(varchar(255), @id_acc)
				SELECT @WhereClause = ' WHERE id_usage_interval=' + @strInterval + ' AND id_pi_template=' + @strPITemplate + ' AND id_view=' + @strView + ' AND id_acc=' + @strAccount

				SELECT 
					@pv_delete_stmt = 'DELETE FROM ' + @nm_productview +  ' WHERE 
					exists (select 1 from t_acc_usage au '
					 + @WhereClause +
					' and au.id_sess = ' 
					+ @nm_productview + '.id_sess and au.id_usage_interval = '
					+ @nm_productview + '.id_usage_interval)'
				SELECT 
					@usage_delete_stmt = 'DELETE FROM t_acc_usage'  + @WhereClause
				BEGIN TRAN
					EXECUTE(@pv_delete_stmt)
					EXECUTE(@usage_delete_stmt)
				COMMIT TRAN
			