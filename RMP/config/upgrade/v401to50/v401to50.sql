				set nocount on
				go
				INSERT INTO t_sys_upgrade
				(target_db_version, dt_start_db_upgrade, db_upgrade_status)
				VALUES
				('5.0', getdate(), 'R')
				go
				DECLARE @name varchar(1000)
				declare @stmt nvarchar(2000)
				select  
				@name = ctu.CONSTRAINT_NAME 
				from information_schema.referential_constraints rc
				inner join information_schema.constraint_table_usage ctu
				on ctu.constraint_catalog = rc.constraint_catalog
				and ctu.constraint_schema = rc.constraint_schema
				and ctu.constraint_name = rc.constraint_name
				inner join information_schema.table_constraints tc
				on tc.constraint_catalog = rc.unique_constraint_catalog
				and tc.constraint_schema = rc.unique_constraint_schema
				and tc.constraint_name = rc.unique_constraint_name
				inner join information_schema.constraint_column_usage ccu
				on ctu.constraint_catalog = ccu.constraint_catalog
				and ctu.constraint_schema = ccu.constraint_schema
				and ctu.constraint_name = ccu.constraint_name
				where tc.TABLE_NAME = 'T_ACC_USAGE'
				and ctu.table_name='T_ADJUSTMENT_TRANSACTION'
				select @stmt = N'alter table T_ADJUSTMENT_TRANSACTION drop constraint ' + @name
				exec sp_executesql @stmt
				go
				drop index t_acc_usage.idx_acc_ui_view_ind
				DROP INDEX t_acc_usage.parent_idx_t_acc_usage
				drop index t_acc_usage.idx_payee_ind
				alter table t_acc_usage drop constraint C_t_acc_usage
				go
				declare @name varchar(1000)
				declare @stmt nvarchar(2000) 
				select @name = a.name from sysobjects a, sysobjects b,sysconstraints c
				where a.xtype='PK'
				and b.xtype='U'
				and b.name='T_ACC_USAGE'
				and a.id=c.constid
				and b.id=c.id
				select @stmt = N'alter table t_acc_usage drop constraint ' + @name
				exec sp_executesql @stmt
				go
				DROP INDEX [dbo].[t_adjustment_transaction].[t_adjustment_transaction_fk3idx]
				GO
				alter table t_adjustment_transaction alter column id_sess bigint null
				alter table t_adjustment_transaction alter column id_parent_sess bigint null
				go
				CREATE NONCLUSTERED INDEX [t_adjustment_transaction_fk3idx] ON [dbo].[t_adjustment_transaction] ([id_sess])
				GO
				CREATE TABLE t_archive_partition
				(
				partition_name nvarchar (4000) NULL,
				status char (1) NULL,
				tt_start datetime NULL,
				tt_end datetime NULL
				)				go
				CREATE TABLE t_backup_partition
				(
				partname nvarchar (4000) NULL,
				type char (1) NULL,
				last_backup_time datetime NULL,
				partition_status char (1)  NULL
				)
				go
				CREATE TABLE [dbo].[t_updatestats_partition]
				(
				[partname] [nvarchar] (4000)  NULL,
				[last_stats_time] [datetime] NULL,
				[partition_status] [char] (1)  NULL,
				[Usage_Sampling_Ratio] [int] NULL,
				[Non_Usage_Sampling_Ratio] [int] NULL,
				[H_Sampling_Ratio] [int] NULL
				)
				GO
				declare @name nvarchar(4000)
				declare c1 cursor for
				select distinct a.name from sysindexes a
				inner join sysobjects d on a.id=d.id
				and d.xtype='U'
				and d.name = 't_dm_account'
				and a.name not like '_WA%'
				order by a.name
				open c1
				fetch next from c1 into @name
				WHILE @@FETCH_STATUS = 0
				BEGIN
					exec ('DROP INDEX t_dm_account.' + @name)
					FETCH NEXT FROM c1 into @name
				END
				close c1
				deallocate c1
				go
				CREATE CLUSTERED INDEX idx_dm_account ON dbo.t_dm_account (id_dm_acc)
				GO
				CREATE NONCLUSTERED INDEX idx1_dm_account ON dbo.t_dm_account (id_acc)
				GO
				declare @name nvarchar(4000)
				declare c1 cursor for
				select distinct a.name from sysindexes a
				inner join sysobjects d on a.id=d.id
				and d.xtype='U'
				and d.name = 't_dm_account_ancestor'
				and a.name not like '_WA%'
				order by a.name
				open c1
				fetch next from c1 into @name
				WHILE @@FETCH_STATUS = 0
				BEGIN
					exec ('DROP INDEX t_dm_account_ancestor .' + @name)
					FETCH NEXT FROM c1 into @name
				END
				close c1
				deallocate c1
				go
				CREATE CLUSTERED INDEX idx_dm_account_ancestor ON dbo.t_dm_account_ancestor (id_dm_descendent)
				GO
				CREATE NONCLUSTERED INDEX idx1_dm_account_ancestor ON dbo.t_dm_account_ancestor (id_dm_ancestor, num_generations)
				GO
				IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id('t_dm_payer_interval'))
				begin
				exec sp_rename 't_dm_payer_interval','t_mv_payer_interval'
				end
				go
				IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id('t_dm_payee_session'))
				begin
				drop table t_dm_payee_session
				end
				go
				IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id('t_dm_sess'))
				begin
				drop table t_dm_sess
				end
				go
				select * into tmp_t_usage_interval from t_usage_interval
				create index idx_tmp_t_usage_interval on tmp_t_usage_interval(id_interval)
				go
				alter table t_pc_interval drop constraint pk_t_pc_interval
				alter table t_acc_usage_interval drop constraint fk2_t_acc_usage_interval
				drop index t_acc_usage_interval.fk2idx_t_acc_usage_interval
				alter table t_acc_usage_interval drop constraint pk_t_acc_usage_interval
				GO
				update t_pc_interval set id_interval = (power(2,16) * datediff(day,'1970-01-01 00:00:00',dt_end)) + id_cycle
				update usage set id_usage_interval = (power(2,16) * datediff(day,'1970-01-01 00:00:00',dt_end)) + id_usage_cycle
				from t_acc_usage_interval usage inner join t_usage_interval intv on usage.id_usage_interval=intv.id_interval
				--THIS OPERATION IS EXPENSIVE
				update au set id_usage_interval = (power(2,16) * datediff(day,'1970-01-01 00:00:00',dt_end)) + id_usage_cycle
				from t_acc_usage au inner join t_usage_interval iv
				on au.id_usage_interval = iv.id_interval
				GO
				alter table t_usage_interval drop constraint PK_t_usage_interval
				go
				update t_usage_interval set id_interval = (power(2,16) * datediff(day,'1970-01-01 00:00:00',dt_end)) + id_usage_cycle
				go
				update inv set id_interval = inte.id_interval from
				t_invoice inv inner join tmp_t_usage_interval inte1 on inv.id_interval=inte1.id_interval
				inner join t_usage_interval inte  on inte1.dt_start = inte.dt_start and inte1.dt_end = inte.dt_end
				go
				alter table t_acc_usage alter column id_payee int not null
				alter table t_acc_usage alter column id_sess bigint not null
				alter table t_acc_usage alter column id_parent_sess bigint null
				go
				ALTER TABLE t_acc_usage ADD CONSTRAINT PK_t_acc_usage PRIMARY KEY CLUSTERED (id_sess, id_usage_interval)
				GO
				CREATE INDEX [parent_idx_t_acc_usage] ON [dbo].[t_acc_usage] ([id_parent_sess])
				create index idx_acc_ui_view_ind on t_acc_usage(id_acc, id_usage_interval, id_view)
				create index idx_payee_ind on t_acc_usage(id_payee, dt_session)
				alter table t_acc_usage add constraint C_t_acc_usage unique(tx_uid)
				alter table t_acc_usage_interval add constraint PK_t_acc_usage_interval primary key (id_acc, id_usage_interval)
				create index fk2idx_t_acc_usage_interval on t_acc_usage_interval (id_usage_interval)
				alter table t_usage_interval add constraint PK_t_usage_interval primary key (id_interval)
				alter table t_acc_usage_interval add constraint fk2_t_acc_usage_interval foreign key(id_usage_interval) REFERENCES t_usage_interval (id_interval)
				alter table t_pc_interval add constraint PK_t_pc_interval primary key(id_interval)
				go
				drop table tmp_t_usage_interval
				go
				CREATE TABLE t_mview_catalog
				(id_mv int IDENTITY (1, 1) NOT NULL,
				name nvarchar (200) NOT NULL,
				table_name nvarchar(200) not null,
				description nvarchar (4000),
				update_mode varchar (1) NOT NULL,
				query_path nvarchar (4000) NOT NULL,
				create_query_tag nvarchar (200) NOT NULL,
				full_query_tag nvarchar(200) not null,
				progid nvarchar (200) NOT NULL,
				id_revision int NOT NULL,
				tx_checksum varchar (100) NOT NULL,
				PRIMARY KEY
				(
					id_mv
				))
				go
				CREATE TABLE t_mview_event
				(	id_event int IDENTITY (1, 1) NOT NULL,
				id_mv int NOT NULL,
				description nvarchar (4000),
				PRIMARY KEY
				(
					id_event
				),
				FOREIGN KEY 
				(
					id_mv
				) REFERENCES t_mview_catalog (
					id_mv
				)	)
				go
				CREATE TABLE t_mview_queries (
				id_event int NOT NULL,
				operation_type varchar (1),
				update_query_tag nvarchar (200),
				FOREIGN KEY 
				(
					id_event
				) REFERENCES t_mview_event (
					id_event
				)	)
				go	
				CREATE TABLE t_mview_base_tables (
					id_event int NOT NULL,
					base_table_name nvarchar (200),
					FOREIGN KEY 
					(
						id_event
					) REFERENCES t_mview_event (
						id_event
					)	)
				go					
				CREATE TABLE t_mview_map (
					base_table_name nvarchar (200) NOT NULL,
					mv_name nvarchar (200) NOT NULL,
					global_index int NOT NULL	)
				go
				CREATE TABLE [t_partition] (
				[id_partition] [int] IDENTITY (1, 1) NOT NULL ,
				[partition_name] [nvarchar] (30) NOT NULL ,
				[dt_start] [datetime] NOT NULL ,
				[dt_end] [datetime] NOT NULL ,
				[id_interval_start] [int] NOT NULL ,
				[id_interval_end] [int] NOT NULL ,
				[b_default] [char] (1) NOT NULL ,
				[b_active] [char] (1) NOT NULL ,
				CONSTRAINT [pk_t_partition] PRIMARY KEY  CLUSTERED 
				(
					[id_partition]
				)  ,
				CONSTRAINT [uk1_t_partition] UNIQUE  NONCLUSTERED 
				(
					[partition_name]
				) ) 
				go
				CREATE TABLE [t_partition_interval_map] (
				[id_partition] [int] NOT NULL ,
				[id_interval] [int] NOT NULL 
				CONSTRAINT [pk_t_partition_interval_map] PRIMARY KEY  CLUSTERED 
				(
					[id_partition], [id_interval]
				)
				) 
				go
				ALTER TABLE [dbo].[t_partition_interval_map] ADD
				CONSTRAINT [fk1_t_partition_interval_map] FOREIGN KEY ([id_partition]) REFERENCES [dbo].[t_partition] ([id_partition]),
				CONSTRAINT [fk2_t_partition_interval_map] FOREIGN KEY ([id_interval]) REFERENCES [dbo].[t_usage_interval] ([id_interval])
				GO
				CREATE NONCLUSTERED INDEX [t_partition_inveral_map_fk2idx] ON [dbo].[t_partition_interval_map] ([id_interval])
				GO
				create table [t_partition_storage] (
      				[id_path] [int] not null ,
      				[b_next] [char] (1) ,
      				[path] [varchar] (500) 
      				constraint [pk_t_partition_storage] primary key  clustered 
      				(
      					[id_path]
      				) 
				)
				go
--				ALTER TABLE [dbo].[t_payment_audit] ALTER COLUMN [nm_accounttype] [nvarchar] (64) NULL
--				GO
				ALTER TABLE [dbo].[t_usage_server] ADD
				[b_partitioning_enabled] [nvarchar] (1) NOT NULL CONSTRAINT [DF_t_usage_server_1] DEFAULT ('N'),
				[partition_cycle] [int] NOT NULL CONSTRAINT [DF_t_usage_server_2] DEFAULT (30),
				[partition_type] [nvarchar] (20) NOT NULL CONSTRAINT [DF_t_usage_server_3] DEFAULT ('Monthly'),
				[partition_data_size] [int] NOT NULL CONSTRAINT [DF_t_usage_server_4] DEFAULT (100),
				[partition_log_size] [int] NOT NULL CONSTRAINT [DF_t_usage_server_5] DEFAULT (25)
				GO
				declare @name varchar(4000)
				declare @cmd nvarchar(4000)
				declare c1 cursor for SELECT distinct nm_table_name from t_prod_view 
				open c1
				fetch next from c1 into @name
				while @@fetch_status = 0
				begin
				set @cmd = 'alter table ' + @name + ' add id_usage_interval int '
				exec (@cmd)
				fetch next from c1 into @name
				end
				close c1
				deallocate c1
				GO				
				declare @name varchar(4000)
				declare @cmd nvarchar(4000)
				declare c1 cursor for SELECT distinct nm_table_name from t_prod_view 
				open c1
				fetch next from c1 into @name
				while @@fetch_status = 0
				begin
				set @cmd = 'update pv set id_usage_interval = au.id_usage_interval from ' + @name + ' pv inner join t_acc_usage au on pv.id_sess = au.id_sess '
				exec (@cmd)
				fetch next from c1 into @name
				end
				close c1
				deallocate c1
				GO
				declare @name varchar(4000)
				declare @cmd nvarchar(4000)
				declare c1 cursor for SELECT distinct nm_table_name from t_prod_view 
				open c1
				fetch next from c1 into @name
				while @@fetch_status = 0
				begin
				set @cmd = 'alter table ' + @name + ' alter column id_usage_interval int not null '
				exec (@cmd)
				fetch next from c1 into @name
				end
				close c1
				deallocate c1
				GO
				declare @name varchar(4000)
				declare @cmd nvarchar(4000)
				declare c1 cursor for SELECT distinct nm_table_name from t_prod_view
				open c1
				fetch next from c1 into @name
				while @@fetch_status = 0
				begin
					declare @name1 varchar(1000)
					declare @stmt nvarchar(2000) 
					select @name1 = a.name from sysobjects a, sysobjects b,sysconstraints c
					where a.xtype='PK'
					and b.xtype='U'
					and b.name= @name
					and a.id=c.constid
					and b.id=c.id
					set @cmd = 'alter table ' + @name + ' drop constraint ' + @name1
					exec (@cmd)
					fetch next from c1 into @name
				end
				close c1
				deallocate c1
				GO
				declare @name varchar(4000)
				declare @cmd nvarchar(4000)
				declare c1 cursor for SELECT distinct nm_table_name from t_prod_view
				open c1
				fetch next from c1 into @name
				while @@fetch_status = 0
				begin
					set @cmd = 'alter table ' + @name + ' alter column id_sess bigint not null '
					exec (@cmd)
					fetch next from c1 into @name
				end
				close c1
				deallocate c1
				GO
				declare @name varchar(4000)
				declare @cmd nvarchar(4000)
				declare c1 cursor for SELECT distinct nm_table_name from t_prod_view
				open c1
				fetch next from c1 into @name
				while @@fetch_status = 0
				begin
					set @cmd = 'ALTER TABLE ' + @name + ' ADD CONSTRAINT PK_' + @name + ' PRIMARY KEY CLUSTERED (id_sess, id_usage_interval)'
					exec (@cmd)
					fetch next from c1 into @name
				end
				close c1
				deallocate c1
				GO
				create table [dbo].[t_unique_cons] (
					[id_unique_cons] [int] identity (1, 1) not null ,
					[id_prod_view] [int] not null ,
					[constraint_name] [nvarchar] (400) not null ,
					[nm_table_name] [nvarchar] (400) not null ,
					constraint [pk_t_unique_cons] primary key  clustered 
					(
						[id_unique_cons]
					) ,
					constraint [uk1_t_unique_cons] unique  nonclustered 
					(
						[constraint_name]
					)
				)
				go
				CREATE NONCLUSTERED INDEX [t_unique_cons_fk1idx] ON [dbo].[t_unique_cons] ([id_prod_view])
				GO
				ALTER TABLE [dbo].[t_unique_cons] ADD CONSTRAINT [fk1_t_unique_cons] FOREIGN KEY ([id_prod_view]) REFERENCES [dbo].[t_prod_view] ([id_prod_view])
				GO
				create table [dbo].[t_unique_cons_columns] (
				[id_unique_cons] [int] not null ,
				[id_prod_view_prop] [int] not null ,
				[position] [int] not null ,
				constraint [pk_t_unique_cons_col] primary key  clustered 
				(
					[id_unique_cons],
					[id_prod_view_prop]
				)  ,
				constraint [uk1_t_unique_cons_col] unique  nonclustered 
				(
					[id_unique_cons],
					[position]
				)  
				)
				go
				CREATE NONCLUSTERED INDEX [t_unique_cons_columns_fk1idx] ON [dbo].[t_unique_cons_columns] ([id_prod_view_prop])
				GO
				ALTER TABLE [dbo].[t_unique_cons_columns] ADD CONSTRAINT [fk1_t_unique_cons_col] FOREIGN KEY ([id_unique_cons]) REFERENCES [dbo].[t_unique_cons] ([id_unique_cons])
				GO
				ALTER TABLE [dbo].[t_unique_cons_columns] ADD CONSTRAINT [fk2_t_unique_cons_col] FOREIGN KEY ([id_prod_view_prop]) REFERENCES [dbo].[t_prod_view_prop] ([id_prod_view_prop])
				GO
--				CREATE NONCLUSTERED INDEX [nm_name_idx] ON [dbo].[t_base_props] ([nm_name])
--				GO
				CREATE TABLE [dbo].[t_current_long_id]
				(
				[id_current] [bigint] NOT NULL,
				[nm_current] [nvarchar] (20) NOT NULL
				)
				GO
				ALTER TABLE [dbo].[t_current_long_id] ADD CONSTRAINT [PK_t_current_long_id] PRIMARY KEY CLUSTERED  ([id_current], [nm_current])
				GO
--				CREATE NONCLUSTERED INDEX [tx_FailureCompoundID_idx] ON [dbo].[t_failed_transaction] ([tx_FailureCompoundID])
--				GO
				ALTER TABLE [dbo].[t_recevent_inst] ADD [id_arg_billgroup] [int] NULL
				GO
				ALTER TABLE [dbo].[t_recevent_inst] ADD [id_arg_root_billgroup] [int] NULL
				GO
				DROP INDEX [dbo].[t_rerun_sessions].[idx_t_rerun_sessions]
				GO
				ALTER TABLE [dbo].[t_rerun_sessions] ALTER COLUMN [id_sess] [bigint] NULL
				ALTER TABLE [dbo].[t_rerun_sessions] ALTER COLUMN [id_parent] [bigint] NULL
				go
				CREATE CLUSTERED INDEX [idx_t_rerun_sessions] ON [dbo].[t_rerun_sessions] ([id_sess])
				GO
				CREATE TABLE t_account_view_log 
				(id_account_view int identity not null primary key,
				nm_account_view nvarchar(100) NOT NULL, 
				id_revision int NOT NULL, 
				tx_checksum varchar(100) NOT NULL,
				nm_table_name varchar(255))
				go
				create table t_account_view_prop ( 
				id_account_view_prop int identity not null,
				id_account_view int not null,
				nm_name nvarchar(255) not null,
				nm_data_type varchar(255) not null,
				nm_column_name nvarchar(255) not null,
				b_required char(1) not null,
				b_composite_idx char(1) not null,
				b_single_idx char(1) not null,
	      			b_part_of_key char(1) not null,
	      			b_exportable char(1) not null,
	      			b_filterable char(1) not null,
	      			b_user_visible char(1) not null,
				nm_default_value nvarchar(255) null,
				n_prop_type int not null,
				nm_space nvarchar(255) null,
				nm_enum nvarchar(255) null,
	      			b_core char(1) not null,
				constraint t_account_view_prop_view_name_IDX unique (id_account_view, nm_name)
	      			)
	      			alter table t_account_view_prop add constraint pk_t_account_view_prop 
	       			primary key(id_account_view_prop)
				go
				CREATE TABLE t_billgroup
				(
				  id_billgroup INT NOT NULL,                     -- primary key
				  tx_name NVARCHAR(50) NOT NULL,                 -- name of this billing group
				  tx_description NVARCHAR(2048) NULL,            -- description for this billing group
				  id_usage_interval INT NOT NULL,                      -- interval associated with this billing group
				  id_parent_billgroup  INT NULL,                         -- id of the parent billing group, if this is the materialization of a pull list
				  tx_type VARCHAR(20) NOT NULL,                     -- The type of materialization. One of: Full, Rematerialization, PullList
				  CONSTRAINT PK_t_billgroup PRIMARY KEY (id_billgroup),
				  CONSTRAINT FK1_t_billgroup FOREIGN KEY (id_usage_interval) REFERENCES t_usage_interval (id_interval),
				  CONSTRAINT FK2_t_billgroup FOREIGN KEY (id_parent_billgroup) REFERENCES t_billgroup (id_billgroup),
				  CONSTRAINT CK1_t_billgroup CHECK (tx_type IN ('UserDefined','Full', 'Rematerialization', 'PullList'))
				)
				go
				CREATE TABLE t_billgroup_materialization
				(
				  id_materialization INT IDENTITY(1000,1) NOT NULL,   -- identity and primary key
				  id_user_acc INT NOT NULL,                                         -- user who performed the action.
				  dt_start DATETIME NOT NULL,                                     -- date this materialization started
				  dt_end DATETIME NULL,                                              -- date this materialization ended
				  id_parent_billgroup  INT NULL,                                    -- id of the parent billing group, if this is the materialization of a pull list
				  id_usage_interval INT NOT NULL,                                -- interval associated with this billing group 
				  tx_status VARCHAR(10) NOT NULL,                             -- The status of the materialization process. 
				                                                                                      --  One of the following:InProgress, Succeeded, Failed, Aborted 
				  tx_failure_reason VARCHAR(4096),                             -- This will contain a description of the error if any occur.
				  tx_type VARCHAR(20) NOT NULL                                -- The type of materialization. One of: Full, Rematerialization, PullList 
				
				  CONSTRAINT PK_t_billgroup_materialization PRIMARY KEY (id_materialization),
				  CONSTRAINT FK1_t_billgroup_materialization FOREIGN KEY (id_user_acc) REFERENCES t_account (id_acc),
				  CONSTRAINT FK3_t_billgroup_materialization FOREIGN KEY (id_usage_interval) REFERENCES t_usage_interval (id_interval),  
				  CONSTRAINT CK1_t_billgroup_materialization CHECK (tx_status IN ('InProgress', 'Succeeded', 'Failed', 'Aborted')),
				  CONSTRAINT CK2_t_billgroup_materialization CHECK (tx_type IN ('UserDefined','Full', 'Rematerialization', 'PullList'))
				)
				go
				CREATE TABLE t_billgroup_member
				(
				  id_billgroup INT NULL,                 -- the billing group identifier
				  id_acc INT NOT NULL,                   -- account which has been mapped to the billing group specified by id_billgroup 
				  id_materialization INT NOT NULL,  -- the materialization which assigned the member account to this billing group
				  id_root_billgroup int null,	
				  CONSTRAINT FK1_t_billgroup_member FOREIGN KEY (id_billgroup) REFERENCES t_billgroup (id_billgroup),
				  CONSTRAINT FK2_t_billgroup_member FOREIGN KEY (id_acc) REFERENCES t_account (id_acc),  
				  CONSTRAINT FK3_t_billgroup_member FOREIGN KEY (id_materialization) REFERENCES t_billgroup_materialization (id_materialization)
				)
				go
				CREATE TABLE t_billgroup_member_history
				(
				  id_billgroup INT NULL,           
				  id_acc INT NOT NULL, 
				  id_materialization INT NOT NULL, 
				  tx_status VARCHAR(10) NOT NULL, 
				  tt_start DATETIME NOT NULL, 
				  tt_end DATETIME NOT NULL,
				  tx_failure_reason varchar(2048) null,
				  CONSTRAINT FK2_t_billgroup_member_history FOREIGN KEY (id_acc) REFERENCES t_account (id_acc),  
				  CONSTRAINT FK3_t_billgroup_member_history FOREIGN KEY (id_materialization) REFERENCES t_billgroup_materialization (id_materialization)
				)
				go
				CREATE TABLE t_billgroup_source_acc
				(
				  id_materialization INT NOT NULL,    -- the materialization for which this account is used as a source
				  id_acc INT NOT NULL                       -- source account for this materialization
				 
				  CONSTRAINT FK1_t_billgroup_source_acc FOREIGN KEY (id_materialization) REFERENCES t_billgroup_materialization (id_materialization),
				  CONSTRAINT FK2_t_billgroup_source_acc FOREIGN KEY (id_acc) REFERENCES t_account (id_acc)
				 )
				go
				CREATE TABLE t_billgroup_tmp
				(
				  id_materialization INT NOT NULL,          -- the materialization which created this billing group.
				  tx_name NVARCHAR(50) NOT NULL,      -- name of this billing group. Must be unique
				  tx_description NVARCHAR(255) NULL,    -- description for this billing group
				  id_billgroup INT IDENTITY(1000,1) NOT NULL  -- identity 
				  
				  CONSTRAINT FK1_t_billgroup_tmp FOREIGN KEY (id_materialization) REFERENCES t_billgroup_materialization (id_materialization)
				 )
				go
				CREATE TABLE t_billgroup_member_tmp
				(
				  id_materialization INT NOT NULL,          -- the materialization which assigned this member account to this billing group name.
				  tx_name NVARCHAR(50) NOT NULL,      -- name of this billing group
				  id_acc INT NOT NULL,                            -- member account assigned to this billing group name.
				  b_extra INT NULL,
				  CONSTRAINT FK1_t_billgroup_member_tmp FOREIGN KEY (id_materialization) REFERENCES t_billgroup_materialization (id_materialization),
				  CONSTRAINT FK2_t_billgroup_member_tmp FOREIGN KEY (id_acc) REFERENCES t_account (id_acc),
				 )
				go
				create table t_param_table_prop ( 
				id_param_table_prop int identity not null,
				id_param_table int not null,
				nm_name nvarchar(255) not null,
				nm_data_type varchar(255) not null,
				nm_column_name nvarchar(255) not null,
				b_required char(1) not null,
				b_composite_idx char(1) not null,
				b_single_idx char(1) not null,
	      			b_part_of_key char(1) not null,
	      			b_exportable char(1) not null,
	      			b_filterable char(1) not null,
	      			b_user_visible char(1) not null,
				nm_default_value nvarchar(255) null,
				n_prop_type int not null,
				nm_space nvarchar(255) null,
				nm_enum nvarchar(255) null,
	      			b_core char(1) not null,
	      			b_columnoperator char(1) not null,
		  		nm_operatorval varchar(50) null,     
				constraint t_param_table_prop_view_name_IDX unique (id_param_table, nm_name)	
	      			)
	      			alter table t_param_table_prop add constraint pk_t_param_table_prop 
	      			 primary key(id_param_table_prop)
				go
				create table t_updatestatsinfo
				(
				ObjectName nvarchar(2000),
				StatPercentChar	nvarchar(2000),
				Duration int
				)
				create clustered index idx_updatestatsinfo on t_updatestatsinfo(objectname)
				go
				alter table t_recevent add tx_billgroup_support VARCHAR(15) NULL
				alter table t_recevent add b_has_billgroup_constraints VARCHAR(1) NULL
				go
				update t_recevent set tx_billgroup_support = 'Interval'
				go
				alter table t_recevent ALTER column tx_billgroup_support VARCHAR(15) NOT NULL
				GO
				ALTER TABLE [dbo].[t_service_def_log] DROP CONSTRAINT [PK_t_service_def_log]
				GO
				CREATE TABLE [dbo].[tmp_rg_xx_t_service_def_log]
				(
				[id_service_def] [int] NOT NULL IDENTITY(1, 1),
				[nm_service_def] [nvarchar] (100) NOT NULL,
				[id_revision] [int] NOT NULL,
				[tx_checksum] [varchar] (100) NOT NULL,
				[nm_table_name] [varchar] (255) NULL
				)
				GO
				INSERT INTO [dbo].[tmp_rg_xx_t_service_def_log]([nm_service_def], [id_revision], [tx_checksum], [nm_table_name]) SELECT [nm_service_def], [id_revision], [tx_checksum], [nm_table_name] FROM [dbo].[t_service_def_log]
				GO
				DROP TABLE [dbo].[t_service_def_log]
				GO
				sp_rename N'[dbo].[tmp_rg_xx_t_service_def_log]', N't_service_def_log'
				GO
				ALTER TABLE [dbo].[t_service_def_log] ADD CONSTRAINT [PK__t_service_def_log] PRIMARY KEY CLUSTERED  ([id_service_def])
				GO
				CREATE TABLE [dbo].[t_account_type]
				(
				[id_type] [int] NOT NULL IDENTITY(1, 1),
				[name] [varchar] (200)  NOT NULL,
				[nm_icon] [varchar] (200)  NULL,
				[b_CanSubscribe] [char] (1)  NOT NULL,
				[b_CanBePayer] [char] (1)  NOT NULL,
				[b_CanHaveSyntheticRoot] [char] (1)  NOT NULL,
				[b_CanParticipateInGSub] [char] (1)  NOT NULL,
				[b_IsVisibleInHierarchy] [char] (1)  NOT NULL,
				[b_CanHaveTemplates] [char] (1)  NOT NULL,
				[b_IsCorporate] [char] (1)  NOT NULL,
				[nm_description] [varchar] (512)  NULL
				)
				GO
				ALTER TABLE [dbo].[t_account_type] ADD CONSTRAINT [pk_t_account_type] PRIMARY KEY CLUSTERED  ([id_type])
				GO
				ALTER TABLE [dbo].[t_account_type] ADD CONSTRAINT [uk_t_account_type_name] UNIQUE NONCLUSTERED  ([name])
				GO
				CREATE TABLE [dbo].[t_account_type_servicedef_map]
				(
				[id_type] [int] NOT NULL,
				[operation] [int] NOT NULL,
				[id_service_def] [int] NOT NULL
				)				
				GO
				ALTER TABLE [dbo].[t_account_type_servicedef_map] ADD CONSTRAINT [pk_t_account_type_servicedef_map] PRIMARY KEY CLUSTERED  ([id_type], [operation])
				GO
				CREATE TABLE [dbo].[t_account_type_view_map]
				(
				[id_type] [int] NOT NULL,
				[id_account_view] [int] NOT NULL
				)				
				GO
				ALTER TABLE [dbo].[t_account_type_view_map] ADD CONSTRAINT [pk_t_account_view_map] PRIMARY KEY CLUSTERED  ([id_type], [id_account_view])
				GO
				CREATE TABLE [dbo].[t_acctype_descendenttype_map]
				(
				[id_type] [int] NOT NULL,
				[id_descendent_type] [int] NOT NULL
				)				
				GO
				ALTER TABLE [dbo].[t_acctype_descendenttype_map] ADD CONSTRAINT [pk_t_acctype_descendenttype_map] PRIMARY KEY CLUSTERED  ([id_type], [id_descendent_type])
				GO
				ALTER TABLE [dbo].[t_acctype_descendenttype_map] ADD CONSTRAINT [fk1_t_acctype_descendenttype_map] FOREIGN KEY ([id_type]) REFERENCES [dbo].[t_account_type] ([id_type])
				GO
				ALTER TABLE [dbo].[t_acctype_descendenttype_map] ADD CONSTRAINT [fk2_t_acctype_descendenttype_map] FOREIGN KEY ([id_descendent_type]) REFERENCES [dbo].[t_account_type] ([id_type])
				GO
				ALTER TABLE [dbo].[t_acc_template_props] DROP CONSTRAINT [FK1_T_ACC_TEMPLATE_PROPS]
				GO
				declare @name varchar(1000)
				declare @stmt nvarchar(2000) 
				select @name = a.name from sysobjects a, sysobjects b,sysconstraints c
				where a.xtype='PK'
				and b.xtype='U'
				and b.name='t_acc_template_subs'
				and a.id=c.constid
				and b.id=c.id
				select @stmt = N'alter table t_acc_template_subs drop constraint ' + @name
				exec sp_executesql @stmt
				go
				ALTER TABLE [dbo].[t_acc_template_subs] add id_group int
				GO
				ALTER TABLE [dbo].[t_acc_template_subs] alter column id_po int null
				GO
				update t_acc_template_subs set id_group = id_po, id_po = null
				where b_group = 'Y'
				go
				alter table t_acc_template_subs drop constraint t_acc_template_subs_check1
				go
				ALTER TABLE [dbo].[t_acc_template_subs] DROP column b_group
				GO
				ALTER TABLE [dbo].[t_acc_template_subs] DROP column nm_groupsubname
				GO
				create CLUSTERED index idx1_t_acc_template_subs on t_acc_template_subs(id_acc_template, id_po)
				create index idx2_t_acc_template_subs on t_acc_template_subs (id_acc_template, id_group)
				alter table t_acc_template_subs add CONSTRAINT t_acc_template_subs_check1 CHECK ((id_po IS NULL AND id_group IS NOT NULL) OR (id_po IS NOT NULL AND id_group IS NULL))
				ALTER TABLE [dbo].[t_acc_template_subs] DROP CONSTRAINT [FK2_T_ACC_TEMPLATE_SUBS]
				GO
				ALTER TABLE [dbo].[t_acc_template_props] ADD
				CONSTRAINT [FK1_T_ACC_TEMPLATE_PROPS] FOREIGN KEY ([id_acc_template]) REFERENCES [dbo].[t_acc_template] ([id_acc_template])
				ALTER TABLE [dbo].[t_acc_template_subs] ADD
				CONSTRAINT [FK2_T_ACC_TEMPLATE_SUBS] FOREIGN KEY ([id_acc_template]) REFERENCES [dbo].[t_acc_template] ([id_acc_template])
				go
				alter table t_account add id_type int
				go
				alter table t_invoice_range add id_billgroup int null
				go
				update t_invoice_range set id_billgroup = -1
				go
				alter table t_invoice_range alter column id_billgroup int not null
				go
				drop table t_se_mapper
				go
				drop table t_se_parent
				go
				alter table t_acc_usage drop constraint fk4_t_acc_usage
				go
				drop table t_service_endpoint
				go
				sp_rename 't_failed_transaction.id_PossibleAccountID','id_PossiblePayeeID'
				go
				alter table t_failed_transaction add id_PossiblePayerID int not null constraint df_t_failed_transaction default '-1'
				go
				CREATE NONCLUSTERED INDEX [t_failed_transaction_batch_idx] ON [dbo].[t_failed_transaction] ([tx_Batch_Encoded])
				GO
				CREATE TABLE t_recevent_run_failure_acc
				(
				id_run INT NOT NULL,    -- the run which created the failed account
				id_acc INT NOT NULL,     -- the account which failed				 
				CONSTRAINT FK1_t_recevent_run_failure_acc FOREIGN KEY (id_run) REFERENCES t_recevent_run (id_run),
				CONSTRAINT FK2_t_recevent_run_failure_acc FOREIGN KEY (id_acc) REFERENCES t_account (id_acc)
				)
				go
				CREATE TABLE [dbo].[t_ReportingDBLog]
				(
				[NameOfReportingDB] [nvarchar] (2000) NOT NULL,
				[doBackup] [varchar] (1) NULL
				)
				ALTER TABLE [dbo].[t_ReportingDBLog] ADD CONSTRAINT [pk_t_ReportingDBLog] PRIMARY KEY CLUSTERED  ([NameOfReportingDB])
				GO
				CREATE TABLE [dbo].[t_service_def_prop]
				(
				[id_service_def_prop] [int] NOT NULL IDENTITY(1, 1),
				[id_service_def] [int] NOT NULL,
				[nm_name] [nvarchar] (255)  NOT NULL,
				[nm_data_type] [varchar] (255)  NOT NULL,
				[nm_column_name] [nvarchar] (255)  NOT NULL,
				[b_required] [char] (1)  NOT NULL,
				[b_composite_idx] [char] (1)  NOT NULL,
				[b_single_idx] [char] (1)  NOT NULL,
				[b_part_of_key] [char] (1)  NOT NULL,
				[b_exportable] [char] (1)  NOT NULL,
				[b_filterable] [char] (1)  NOT NULL,
				[b_user_visible] [char] (1)  NOT NULL,
				[nm_default_value] [nvarchar] (255)  NULL,
				[n_prop_type] [int] NOT NULL,
				[nm_space] [nvarchar] (255)  NULL,
				[nm_enum] [nvarchar] (255)  NULL,
				[b_core] [char] (1)  NOT NULL
				)
				GO
				ALTER TABLE [dbo].[t_service_def_prop] ADD CONSTRAINT [pk_t_service_def_prop] PRIMARY KEY CLUSTERED  ([id_service_def_prop])
				GO
				ALTER TABLE [dbo].[t_service_def_prop] ADD CONSTRAINT [t_service_def_prop_view_name_IDX] UNIQUE NONCLUSTERED  ([id_service_def], [nm_name])
				GO
				ALTER table t_prod_view add b_can_resubmit_from char(1) null
				go
				update t_prod_view set b_can_resubmit_from = 'N'
				GO
				ALTER table t_prod_view alter column b_can_resubmit_from char(1) not null
				go
				ALTER TABLE [dbo].[t_acc_template] DROP CONSTRAINT [pk_t_acc_template]
				GO
				Alter table t_acc_template add id_acc_type int
				go
				create table t_po_account_type_map
				(
				  id_po int NOT NULL,
				  id_account_type int NOT NULL,
				  CONSTRAINT pk_t_po_account_type_map PRIMARY KEY CLUSTERED (id_po, id_account_type)
				)
				go
				ALTER TABLE [dbo].[t_usage_interval] DROP CONSTRAINT [CK1_t_usage_interval]
				GO
				ALTER TABLE [dbo].[t_usage_interval] ADD CONSTRAINT [CK1_t_usage_interval] CHECK (([tx_interval_status] = 'H' or ([tx_interval_status] = 'B' or [tx_interval_status] = 'O')))
				GO
				if not exists (select 1 from t_acc_usage where id_se is not null)
				begin
					update t_acc_usage set id_se = id_payee
				end
				else
				begin
				update t_acc_usage set id_se = id_payee,id_payee=id_se where id_se is not null
				update t_acc_usage set id_se = id_payee where id_se is null
				end
				go
				alter table t_acc_usage alter column id_se int not null
				go
				CREATE TABLE t_billgroup_constraint
				(
					id_usage_interval INT NOT NULL,
					id_group INT NOT NULL,
					id_acc INT NOT NULL
				  
					CONSTRAINT FK1_t_billgroup_constraint FOREIGN KEY (id_usage_interval) REFERENCES t_usage_interval (id_interval),
					CONSTRAINT FK2_t_billgroup_constraint FOREIGN KEY (id_acc) REFERENCES t_account (id_acc)
				)
				go
				CREATE TABLE t_billgroup_constraint_tmp
				(
					id_usage_interval INT NOT NULL,
					id_group INT NOT NULL,
					id_acc INT NOT NULL
				  
					CONSTRAINT FK1_t_billgroup_constraint_tmp FOREIGN KEY (id_usage_interval) REFERENCES t_usage_interval (id_interval),
					CONSTRAINT FK2_t_billgroup_constraint_tmp FOREIGN KEY (id_acc) REFERENCES t_account (id_acc)
				)
				go
				CREATE NONCLUSTERED INDEX [idx1_t_session] ON [dbo].[t_session] ([id_source_sess])
				GO
				ALTER TABLE [dbo].[t_recevent] ADD CONSTRAINT [CK3_t_recevent] CHECK (([tx_billgroup_support] = 'Account' or ([tx_billgroup_support] = 'BillingGroup' or [tx_billgroup_support] = 'Interval')))
				GO
				declare @name varchar(1000)
				declare @stmt nvarchar(2000) 
				select @name = a.name from sysobjects a, sysobjects b,sysconstraints c
				where a.xtype='PK'
				and b.xtype='U'
				and b.name='t_current_id'
				and a.id=c.constid
				and b.id=c.id
				select @stmt = N'alter table t_current_id drop constraint ' + @name
				exec sp_executesql @stmt
				go
				ALTER TABLE t_current_id ADD CONSTRAINT PK_t_current_id PRIMARY KEY CLUSTERED  (nm_current)
				GO
				/* BEGIN OF CORE-3774 */
				/* Migrate these old 4.0 32-bit sequences if not already */
				/* defined in t_current_long_id. */
				insert into t_current_long_id (id_current, nm_current)
				  select CAST(id_current as BIGINT), nm_current
				  from t_current_id oldseq
				  where oldseq.nm_current in ('id_dbqueue', 'id_sess')
				  and not exists (
				   select * from t_current_long_id newseq
				   where newseq.nm_current = oldseq.nm_current
				  )
				go
				/* Remove these old 4.0 32-bit sequences, */
				/* if they exist, from t_current_id. */
				delete from t_current_id
				  where nm_current in ('id_dbqueue', 'id_sess')
				go
				/* Add the 5.0 32-bit sequence id_failed_txn */
				/* if it does not exist. */
				declare @l_max_id INT
				select @l_max_id=COALESCE(MAX(id_failed_transaction),999) 
				  from t_failed_transaction 
				insert into t_current_id (id_current, nm_current)
  				  select @l_max_id + 1, 'id_failed_txn'
				  where not exists
				  (select * from t_current_id where nm_current = 'id_failed_txn')
				go
				/* Add the 5.0 32-bit sequence id_acc */
				/* if it does not exist. */
				declare @l_max_id INT
				select @l_max_id=COALESCE(MAX(id_acc),122) 
				  from t_account 
				insert into t_current_id (id_current, nm_current)
				  select @l_max_id + 1, 'id_acc'
				  where not exists
				  (select * from t_current_id where nm_current = 'id_acc')
				go
				/* END OF CORE-3774 */
				UPDATE t_sys_upgrade
				SET db_upgrade_status = 'M',
				dt_end_db_upgrade = getdate()
				WHERE upgrade_id = (SELECT MAX(upgrade_id) FROM t_sys_upgrade)	
				go
