
		create proc BackoutUniqueKeys (
				@rerun_tab nvarchar(30), 
				@usage_tab nvarchar(30)
				) as
		begin

			-- Quit nicely if partitioning is off
			if (dbo.IsSystemPartitioned() <> 1) begin
				return 0
			end
			
			declare @sql nvarchar(4000)
			declare @keytab varchar(255)
			
			-- get list of unique key table names 
			set @sql = N'declare keycur cursor for
				select uc.nm_table_name 
				from t_unique_cons uc
				join t_prod_view pv on uc.id_prod_view = pv.id_prod_view
				where pv.nm_table_name = ''' + @usage_tab + ''''
			EXEC sp_executesql @sql
			
			-- delete from the unique key tables
			open keycur
			fetch next from keycur into @keytab
			while @@fetch_status = 0
			begin
				set @sql = 'delete uk ' + 
						'from ' + @keytab + ' uk ' +
						'join ' + @rerun_tab + ' rr ' +
		    			'  on uk.id_sess = rr.id_sess where rr.tx_state = ''a'''

				exec (@sql)
				fetch next from keycur into @keytab
			end
			deallocate keycur

		end
    