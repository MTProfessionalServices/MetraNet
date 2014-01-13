
		Create Procedure Backout(@rerun_table_name nvarchar(30), @delete_failed_records VARCHAR(1)) as
		begin
			declare @sql nvarchar(4000)

			-- values we get from the cursor
			declare @tablename varchar(255)
			declare @id_view int

			-- update the state in t_session_state

			-- delete from the productviews.
			set @sql = N'DECLARE tablename_cursor CURSOR FOR
			select rr.id_view, pv.nm_table_name from 
				t_prod_view pv
				inner join ' + @rerun_table_name + N' rr on rr.id_view = pv.id_view
				where rr.tx_state = ''A''
				group by rr.id_view, pv.nm_table_name'
			EXEC sp_executesql @sql

			OPEN tablename_cursor
			FETCH NEXT FROM tablename_cursor into @id_view, @tablename
			WHILE @@FETCH_STATUS = 0
			BEGIN
				set @sql = N'DELETE pv from ' + @tablename
					+ N' pv inner join ' + @rerun_table_name +
					N' rerun on pv.id_sess = rerun.id_sess and pv.id_usage_interval = rerun.id_interval
						where rerun.tx_state = ''A'''
				exec (@sql)

				-- delete from the prod view unique key tables
				exec BackoutUniqueKeys @rerun_table_name, @tablename

				FETCH NEXT FROM tablename_cursor into @id_view, @tablename
			END
			CLOSE tablename_cursor
			DEALLOCATE tablename_cursor

			-- delete from t_acc_usage
			set @sql = N'delete acc from t_acc_usage acc ' +
				N' inner join ' + @rerun_table_name +
				N' rerun on acc.id_sess = rerun.id_sess and acc.id_usage_interval = rerun.id_interval
				where tx_state = ''A'''

			EXEC sp_executesql @sql

			-- delete from t_acc_usage unique key tables
			exec BackoutUniqueKeys @rerun_table_name, 't_acc_usage'

			if (@delete_failed_records = 'Y')
			BEGIN
				-- delete errors from t_failed_transaction and t_failed_transaction_msix
				set @sql = N'delete t_failed_transaction_msix from t_failed_transaction_msix msix
   					inner join t_failed_transaction ft on 
       			ft.id_failed_transaction = msix.id_failed_transaction
  					inner join ' + @rerun_table_name + N' rr on
       			rr.id_source_sess = ft.tx_failurecompoundid
  					where rr.tx_state = ''E'''
		 	
				EXEC sp_executesql @sql

				set @sql = N'delete t_failed_transaction from 
					t_failed_transaction ft
  					inner join ' + @rerun_table_name + N' rr
					on ft.tx_failurecompoundid = rr.id_source_sess
  					where rr.tx_state = ''E'''

				EXEC sp_executesql @sql
			END

		-- update the rerun table so we know these have been backed out
		set @sql = N'update ' + @rerun_table_name + N' set tx_state = ''B'' where (tx_state = ''A'' or tx_state = ''E'')'
		EXEC sp_executesql @sql
		end
    