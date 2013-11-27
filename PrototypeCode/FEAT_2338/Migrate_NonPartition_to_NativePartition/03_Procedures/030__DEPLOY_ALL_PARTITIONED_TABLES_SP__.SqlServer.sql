IF OBJECT_ID('DeployAllPartitionedTables') IS NOT NULL 
DROP PROCEDURE DeployAllPartitionedTables
GO
			/*
				Proc: DeployAllPartitionedTables

				Calls DeployPartitionedTable for all partitioned tables.

			*/
			create proc DeployAllPartitionedTables
			AS
			begin

			-- Env setup
			set nocount on

			-- Abort if system isn't enabled for partitioning
			if dbo.IsSystemPartitioned() = 0
			begin
				raiserror('System not enabled for partitioning.',0,1)
				return 1
			end

			-- Error handling and row counts
			declare @err int   -- last error
			declare @rc int	-- row count

			declare @tab varchar(300)
			DECLARE @partition_schema varchar(100)
			
			PRINT '------ DEPLOYING PRODUCT VIEW TABLES ----------'
			
			declare tabcur cursor for 
			select nm_table_name from t_prod_view order by nm_table_name

			open tabcur
			fetch tabcur into @tab

			while (@@fetch_status >= 0) begin
				print char(13) + 'Deploying ' + @tab

				exec DeployPartitionedTable @tab

				fetch tabcur into @tab
			end
			deallocate tabcur
			
			PRINT '------ IF AMP TABLES EXISTS then uncoment code below ... ----------'
			/*PRINT '------ DEPLOYING AMP TABLES ----------'
			SET @partition_schema = dbo.prtn_GetUsagePartitionSchemaName()
			
			PRINT 'DEPLOYING AGG_CHARGE_AUDIT_TRAIL TABLE'
			IF OBJECT_ID('agg_charge_audit_trail') IS NOT NULL 
				EXEC prtn_CreatePartitionedTable
						@partition_table_name = N'agg_charge_audit_trail',
						@pk_columns = N'id_payee ASC, id_usage_interval ASC, id_sess ASC',
						@partition_schema = @partition_schema,
						@partition_column = N'id_usage_interval'
			
			PRINT 'DEPLOYING AGG_USAGE_AUDIT_TRAIL TABLE'
			IF OBJECT_ID('agg_usage_audit_trail') IS NOT NULL
				EXEC prtn_CreatePartitionedTable
						@partition_table_name = N'agg_usage_audit_trail',
						@pk_columns = N'id_payee ASC, id_usage_interval ASC, id_sess ASC, is_realtime ASC',
						@partition_schema = @partition_schema,
						@partition_column = N'id_usage_interval'*/
			
			

			-- After depolying all partitioned tables, ensure all
			-- partition databases are in full recovery mode
			declare partn cursor for
				select partition_name from t_partition 
				where b_active = 'Y'

			declare @partnm varchar(3000)		-- partition name
			open partn

			print 'Checking database recovery modes...'
			-- Iterate partitions, set recovery mode to full
			while (1=1) begin	
				fetch partn into @partnm
				if (@@fetch_status <> 0)
					break

				if (databasepropertyex(@partnm, 'recovery') <> 'FULL') begin
					print '   Database ' + @partnm + ': Setting RECOVERY mode to FULL '
					exec('alter database ' + @partnm + ' set recovery full')
				end

			end -- while
			deallocate partn

			end	-- proc
 	