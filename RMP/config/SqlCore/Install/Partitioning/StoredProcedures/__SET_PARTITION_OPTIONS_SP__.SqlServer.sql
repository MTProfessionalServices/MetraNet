
			/*
				SetPartitionOptions

				Sets values in t_usage_server.  Also adds metadata to facilitate
				treating t_acc_usage like a product view.

				@enable char(1)  -- Y if partitions enabled
				@type varchar(20) -- partition cycle type
				@datasize int		-- Size of data file in MB
				@logsize int	-- size of log file in MB

			*/
			create proc SetPartitionOptions
				@enable char(1),  -- Y if partitions enabled
				@type varchar(20), -- partition cycle type
				@datasize int,		-- Size of data file in MB
				@logsize int	-- size of log file in MB
			AS
			begin

			set nocount on

			-- Error reporting and row counts
			declare @err int
			declare @rc int

			-- validate enable flag
			if lower(@enable) not in ('y', 'n') begin
				raiserror('Enbable flag must be "Y" or "N", not "%s"', 16, 1, @enable)
				return
			end

			-- get cycle id
			declare @cycle int

			-- find cycle id for a supported partition cycle
			select @cycle = uc.id_usage_cycle, @type = uct.tx_desc
			from  t_usage_cycle uc
			join t_usage_cycle_type uct
				on uct.id_cycle_type = uc.id_cycle_type
			where lower(uct.tx_desc) = lower(@type)
				and ((uc.id_cycle_type = 1 -- monthly
						and day_of_month = 31)
					or (uc.id_cycle_type = 4 -- weekly
	  					and day_of_week = 1)
					or (uc.id_cycle_type = 6  -- semi-montly
	  					and first_day_of_month = 14 and second_day_of_month = 31)
					or (uc.id_cycle_type = 7  -- quarterly
	  					and start_day = 1 and start_month = 1)
					or (uc.id_cycle_type = 3  -- daily
					))

			if (@cycle is null) begin
				raiserror('Partition type "%s" not supported.', 16, 1, @type)
				return
			end


			begin tran

				-- Update t_usage_server
				update t_usage_server set
					b_partitioning_enabled = upper(@enable),
					partition_cycle = @cycle,
					partition_type = @type,
					partition_data_size = @datasize,
					partition_log_size = @logsize
				
				set @err = @@error
				if (@err <> 0) begin
					raiserror('Cannot update t_usage_server.',1,1)
					rollback
					return
				end

				-- Treat t_acc_usage kinda like a product view
				if not exists (select * from t_prod_view where nm_table_name = 't_acc_usage')
				begin
					declare @prodid int
					declare @enumid int

					-- get the enum id for the acc_usage_table
					select @enumid = id_enum_data
					from t_enum_data
					where lower(nm_enum_data) = 'usage'

					insert t_prod_view 
						(id_view, dt_modified, nm_name, nm_table_name,b_can_resubmit_from)
						values 
						(@enumid, getdate(), 'metratech.com/acc_usage', 't_acc_usage','N')
					set @err = @@error
					set @prodid = @@identity
					if (@err <> 0) begin
						raiserror('Cannot insert to t_prod_view',1,1)
						rollback
						return
					end

					-- add acc_usage columns to t_prod_view_prop
					insert into t_prod_view_prop( 
						/*id_prod_view_prop, */id_prod_view, nm_name, nm_data_type, nm_column_name, 
						b_required, b_composite_idx, b_single_idx, b_part_of_key, b_exportable, 
						b_filterable, b_user_visible, nm_default_value, n_prop_type, nm_space, 
						nm_enum, b_core) 
					SELECT 
						--d_prod_view_prop,
						@prodid as id_prod_view,
						column_name as nm_name, 
						data_type as nm_data_type, 
						column_name as nm_column_name, 
						'Y' as b_required, 
						'N' as b_composite_idx, 
						'N' as b_single_idx, 
						'N' as b_part_of_key, 
						'Y' as b_exportable, 
						'Y' as b_filterable, 
						'Y' as b_user_visible, 
						null as nm_default_value, 	
						0 as n_prop_type, 
						null as nm_space, 
						null as nm_enum, 
						case when column_name like 'id%' then 'Y' else 'N' end as b_core 
					from information_schema.columns
					where table_name = 't_acc_usage'
					
					-- make tx_uid a uniquekey
					declare @ukid int
					declare @pvid int
					
					select @pvid = id_prod_view 
					from t_prod_view
					where nm_table_name = 't_acc_usage'
					
					insert into t_unique_cons (id_prod_view, constraint_name, nm_table_name)
						values (@pvid, 'uk_acc_usage_tx_uid', 't_uk_acc_usage_tx_uid')
					set @ukid = @@identity

					if (@err <> 0) begin
						raiserror('Cannot insert to t_unique_cons',1,1)
						rollback
						return
					end

					insert into t_unique_cons_columns
						select @ukid, id_prod_view_prop, 1
						from t_prod_view_prop
						where id_prod_view = @pvid
							and lower(nm_name) = 'tx_uid'

					if (@err <> 0) begin
						raiserror('Cannot insert to t_unique_cons_columns',1,1)
						rollback
						return
					end
				end

			commit

			return

			end
 	